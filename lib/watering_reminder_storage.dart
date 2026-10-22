// FlowerFinder - Watering Reminder Storage
// Created by Hita

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WateringReminderSettings {
  final String plantId;
  final String plantName;
  final DateTime reminderTime;

  // 0 = once, 1 = daily, 7 = weekly.
  final int repeatDays;
  final bool enabled;

  const WateringReminderSettings({
    required this.plantId,
    required this.plantName,
    required this.reminderTime,
    required this.repeatDays,
    required this.enabled,
  });

  String get frequencyLabel {
    switch (repeatDays) {
      case 1:
        return 'Daily';
      case 7:
        return 'Weekly';
      default:
        return 'Once';
    }
  }

  // Calculates the next occurrence using local calendar dates.
  DateTime nextOccurrence({DateTime? now}) {
    final current = (now ?? DateTime.now()).toLocal();
    final selected = reminderTime.toLocal();

    if (repeatDays == 0) return selected;

    if (!const [1, 7].contains(repeatDays)) {
      throw ArgumentError('Choose once, daily or weekly.');
    }

    for (var offset = 0; offset <= 7; offset++) {
      final candidate = DateTime(
        current.year,
        current.month,
        current.day + offset,
        selected.hour,
        selected.minute,
      );

      final matchesDay =
          repeatDays == 1 || candidate.weekday == selected.weekday;

      if (matchesDay && candidate.isAfter(current)) {
        return candidate;
      }
    }

    throw StateError('Could not calculate the next reminder.');
  }

  Map<String, dynamic> toJson() {
    return {
      'plantId': plantId,
      'plantName': plantName,
      'reminderTime': reminderTime.toUtc().toIso8601String(),
      'repeatDays': repeatDays,
      'enabled': enabled,
    };
  }

  factory WateringReminderSettings.fromJson(
    Map<String, dynamic> json,
  ) {
    final plantId = json['plantId'];
    final plantName = json['plantName'];
    final reminderTime = json['reminderTime'];
    final repeatDays = json['repeatDays'];
    final enabled = json['enabled'];

    if (plantId is! String ||
        plantId.trim().isEmpty ||
        plantName is! String ||
        reminderTime is! String ||
        repeatDays is! int ||
        !const [0, 1, 7].contains(repeatDays) ||
        enabled is! bool) {
      throw const FormatException('Invalid saved reminder settings.');
    }

    // Extra fields from an older version are safely ignored.
    return WateringReminderSettings(
      plantId: plantId,
      plantName: plantName,
      reminderTime: DateTime.parse(reminderTime).toLocal(),
      repeatDays: repeatDays,
      enabled: enabled,
    );
  }
}

class WateringReminderStorage {
  String _key(String plantId) {
    if (plantId.trim().isEmpty) {
      throw ArgumentError('A saved plant ID is required.');
    }

    return 'watering.settings.$plantId';
  }

  Future<WateringReminderSettings?> load(String plantId) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_key(plantId));

    if (saved == null) return null;

    final decoded = jsonDecode(saved);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid saved reminder settings.');
    }

    final settings = WateringReminderSettings.fromJson(decoded);

    if (settings.plantId != plantId) {
      throw const FormatException('Reminder belongs to another plant.');
    }

    return settings;
  }

  Future<void> save(WateringReminderSettings settings) async {
    if (!const [0, 1, 7].contains(settings.repeatDays)) {
      throw ArgumentError('Choose once, daily or weekly.');
    }

    final preferences = await SharedPreferences.getInstance();

    final success = await preferences.setString(
      _key(settings.plantId),
      jsonEncode(settings.toJson()),
    );

    if (!success) {
      throw StateError('Could not save watering reminder settings.');
    }
  }
}