// FlowerFinder - Watering Reminder Tests
// Created by Hita
// US19: Schedule, cancel and validate watering reminders.

import 'package:flutter_test/flutter_test.dart';
import 'package:flowerfinderscanner/watering_reminder_service.dart';

class FakeReminderScheduler implements ReminderScheduler {
  String? scheduledPlantId;
  String? scheduledPlantName;
  DateTime? scheduledTime;
  String? cancelledPlantId;

  @override
  Future<void> schedule({
    required String plantId,
    required String plantName,
    required DateTime reminderTime,
  }) async {
    scheduledPlantId = plantId;
    scheduledPlantName = plantName;
    scheduledTime = reminderTime;
  }

  @override
  Future<void> cancel({required String plantId}) async {
    cancelledPlantId = plantId;

    if (scheduledPlantId == plantId) {
      scheduledPlantId = null;
      scheduledPlantName = null;
      scheduledTime = null;
    }
  }
}

void main() {
  test('Enabling reminders schedules the correct plant and time', () async {
    final scheduler = FakeReminderScheduler();
    final service = WateringReminderService(scheduler: scheduler);
    final reminderTime = DateTime.utc(2030, 1, 15, 9);

    await service.enableReminder(
      plantId: 'plant-1',
      plantName: 'Rose',
      reminderTime: reminderTime,
    );

    expect(scheduler.scheduledPlantId, 'plant-1');
    expect(scheduler.scheduledPlantName, 'Rose');
    expect(scheduler.scheduledTime, reminderTime);
  });

  test('Disabling reminders cancels the correct plant reminder', () async {
    final scheduler = FakeReminderScheduler();
    final service = WateringReminderService(scheduler: scheduler);

    await service.enableReminder(
      plantId: 'plant-1',
      plantName: 'Rose',
      reminderTime: DateTime.utc(2030, 1, 15, 9),
    );

    await service.disableReminder(plantId: 'plant-1');

    expect(scheduler.cancelledPlantId, 'plant-1');
    expect(scheduler.scheduledPlantId, isNull);
    expect(scheduler.scheduledTime, isNull);
  });

  test('A reminder time in the past is rejected without scheduling', () async {
    final scheduler = FakeReminderScheduler();
    final service = WateringReminderService(scheduler: scheduler);

    await expectLater(
      service.enableReminder(
        plantId: 'plant-1',
        plantName: 'Rose',
        reminderTime: DateTime.utc(2000, 1, 1, 9),
      ),
      throwsArgumentError,
    );

    expect(scheduler.scheduledPlantId, isNull);
    expect(scheduler.scheduledTime, isNull);
  });
}