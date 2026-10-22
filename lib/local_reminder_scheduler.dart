// FlowerFinder - Device Watering Notifications
// Created by Hita
// Uses the original notification sound.

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'watering_reminder_service.dart';

class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler._();

  static final LocalReminderScheduler instance =
      LocalReminderScheduler._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialised = false;
  Future<void>? _initialisation;

  // Prevents different plants being allocated the same ID concurrently.
  Future<void> _idQueue = Future<void>.value();

  Future<void> initialise() async {
    if (_initialised) return;

    final pending = _initialisation;

    if (pending != null) {
      await pending;
      return;
    }

    final task = _initialiseDevice();
    _initialisation = task;

    try {
      await task;
      _initialised = true;
    } finally {
      _initialisation = null;
    }
  }

  Future<void> _initialiseDevice() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      throw UnsupportedError(
        'Watering notifications currently support iOS and Android.',
      );
    }

    tz_data.initializeTimeZones();

    final deviceTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    await initialise();

    if (Platform.isIOS) {
      final implementation = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      return await implementation?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    final implementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    return await implementation?.requestNotificationsPermission() ??
        false;
  }

  // Keeps the existing tested service interface unchanged.
  ReminderScheduler withOptions({required int repeatDays}) {
    if (!const [0, 1, 7].contains(repeatDays)) {
      throw ArgumentError('Choose once, daily or weekly.');
    }

    return _ConfiguredReminderScheduler(
      scheduler: this,
      repeatDays: repeatDays,
    );
  }

  Future<int> _notificationId(String plantId) {
    final result = _idQueue.then<int>(
      (_) => _allocateNotificationId(plantId),
    );

    _idQueue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    return result;
  }

  Future<int> _allocateNotificationId(String plantId) async {
    if (plantId.trim().isEmpty) {
      throw ArgumentError('A saved plant ID is required.');
    }

    final preferences = await SharedPreferences.getInstance();
    final key = 'watering.notificationId.$plantId';
    final existingId = preferences.getInt(key);

    if (existingId != null) return existingId;

    final nextId =
        preferences.getInt('watering.nextNotificationId') ?? 1;

    if (nextId < 1 || nextId >= 2147483647) {
      throw StateError('Notification ID limit reached.');
    }

    final reserved = await preferences.setInt(
      'watering.nextNotificationId',
      nextId + 1,
    );

    if (!reserved) {
      throw StateError('Could not reserve a notification ID.');
    }

    final stored = await preferences.setInt(key, nextId);

    if (!stored) {
      throw StateError('Could not save the plant notification ID.');
    }

    return nextId;
  }

  @override
  Future<void> schedule({
    required String plantId,
    required String plantName,
    required DateTime reminderTime,
  }) {
    return scheduleWithOptions(
      plantId: plantId,
      plantName: plantName,
      reminderTime: reminderTime,
      repeatDays: 0,
    );
  }

  Future<void> scheduleWithOptions({
    required String plantId,
    required String plantName,
    required DateTime reminderTime,
    required int repeatDays,
  }) async {
    await initialise();

    if (!const [0, 1, 7].contains(repeatDays)) {
      throw ArgumentError('Choose once, daily or weekly.');
    }

    if (!reminderTime.isAfter(DateTime.now())) {
      throw ArgumentError('The reminder time must be in the future.');
    }

    final id = await _notificationId(plantId);

    final DateTimeComponents? recurrence;

    switch (repeatDays) {
      case 1:
        recurrence = DateTimeComponents.time;
        break;
      case 7:
        recurrence = DateTimeComponents.dayOfWeekAndTime;
        break;
      default:
        recurrence = null;
    }

    // Reusing the plant's notification ID updates its existing reminder.
    await _notifications.zonedSchedule(
      id: id,
      title: 'Time to water your plant',
      body: 'Your $plantName is due for watering.',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'flowerfinder_watering',
          'Watering reminders',
          channelDescription: 'Reminders to water your saved plants',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: recurrence,
      payload: plantId,
    );
  }

  @override
  Future<void> cancel({required String plantId}) async {
    await initialise();

    if (plantId.trim().isEmpty) {
      throw ArgumentError('A saved plant ID is required.');
    }

    final preferences = await SharedPreferences.getInstance();
    final id = preferences.getInt('watering.notificationId.$plantId');

    if (id != null) {
      await _notifications.cancel(id: id);
    }
  }
}

class _ConfiguredReminderScheduler implements ReminderScheduler {
  final LocalReminderScheduler scheduler;
  final int repeatDays;

  const _ConfiguredReminderScheduler({
    required this.scheduler,
    required this.repeatDays,
  });

  @override
  Future<void> schedule({
    required String plantId,
    required String plantName,
    required DateTime reminderTime,
  }) {
    return scheduler.scheduleWithOptions(
      plantId: plantId,
      plantName: plantName,
      reminderTime: reminderTime,
      repeatDays: repeatDays,
    );
  }

  @override
  Future<void> cancel({required String plantId}) {
    return scheduler.cancel(plantId: plantId);
  }
}