// FlowerFinder - Watering Reminder Service
// Created by Hita
// US19: Schedule, cancel and validate watering reminders.

abstract class ReminderScheduler {
  Future<void> schedule({
    required String plantId,
    required String plantName,
    required DateTime reminderTime,
  });

  Future<void> cancel({required String plantId});
}

class WateringReminderService {
  final ReminderScheduler scheduler;

  WateringReminderService({required this.scheduler});

  Future<void> enableReminder({
    required String plantId,
    required String plantName,
    required DateTime reminderTime,
  }) async {
    // Only allows reminders scheduled for a future time.
    if (!reminderTime.isAfter(DateTime.now())) {
      throw ArgumentError.value(
        reminderTime,
        'reminderTime',
        'The reminder time must be in the future.',
      );
    }

    await scheduler.schedule(
      plantId: plantId,
      plantName: plantName,
      reminderTime: reminderTime,
    );
  }

  Future<void> disableReminder({required String plantId}) async {
    await scheduler.cancel(plantId: plantId);
  }
}