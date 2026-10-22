// FlowerFinder - Watering Reminder Page
// Created by Hita

import 'package:flutter/material.dart';

import 'local_reminder_scheduler.dart';
import 'watering_reminder_service.dart';
import 'watering_reminder_storage.dart';

class WateringReminderPage extends StatefulWidget {
  final String plantId;
  final String plantName;

  const WateringReminderPage({
    super.key,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<WateringReminderPage> createState() =>
      _WateringReminderPageState();
}

class _WateringReminderPageState extends State<WateringReminderPage> {
  final _storage = WateringReminderStorage();
  final _scheduler = LocalReminderScheduler.instance;

  DateTime _time = DateTime.now().add(const Duration(minutes: 5));
  int _repeatDays = 0;

  WateringReminderSettings? _saved;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final saved = await _storage.load(widget.plantId);

      if (!mounted) return;

      setState(() {
        _saved = saved;

        if (saved != null) {
          _repeatDays = saved.repeatDays;

          final next = saved.nextOccurrence();
          _time = next.isAfter(DateTime.now())
              ? next
              : DateTime.now().add(const Duration(minutes: 5));
        }

        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load reminder settings. Please try again.';
      });
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _format(DateTime value) {
    final local = value.toLocal();
    final date = MaterialLocalizations.of(context).formatMediumDate(local);
    final time = TimeOfDay.fromDateTime(local).format(context);

    return '$date at $time';
  }

  WateringReminderSettings _draft() {
    return WateringReminderSettings(
      plantId: widget.plantId,
      plantName: widget.plantName,
      reminderTime: _time,
      repeatDays: _repeatDays,
      enabled: true,
    );
  }

  Future<void> _chooseTime() async {
    final now = DateTime.now();
    DateTime date = _time.isAfter(now) ? _time : now;

    // Daily reminders only need a time.
    // Weekly reminders use the weekday of the selected date.
    if (_repeatDays != 1) {
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: DateTime(now.year + 5, 12, 31),
      );

      if (selectedDate == null || !mounted) return;
      date = selectedDate;
    }

    if (!mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );

    if (selectedTime == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (_repeatDays == 0 && !selected.isAfter(DateTime.now())) {
      _message('Choose a time in the future.');
      return;
    }

    setState(() => _time = selected);
  }

  Future<void> _enable() async {
    setState(() => _busy = true);

    final previous = _saved;

    try {
      final next = _draft().nextOccurrence();

      if (!next.isAfter(DateTime.now())) {
        throw ArgumentError('Choose a time in the future.');
      }

      final allowed = await _scheduler.requestPermission();

      if (!mounted) return;

      if (!allowed) {
        _message(
          'Notifications are disabled. Allow them in your phone settings.',
        );
        return;
      }

      // Uses the service covered by the existing three TDD tests.
      final service = WateringReminderService(
        scheduler: _scheduler.withOptions(repeatDays: _repeatDays),
      );

      await service.enableReminder(
        plantId: widget.plantId,
        plantName: widget.plantName,
        reminderTime: next,
      );

      final settings = WateringReminderSettings(
        plantId: widget.plantId,
        plantName: widget.plantName,
        reminderTime: next,
        repeatDays: _repeatDays,
        enabled: true,
      );

      try {
        await _storage.save(settings);
      } catch (_) {
        // Avoid leaving a newly scheduled reminder without saved settings.
        await _scheduler.cancel(plantId: widget.plantId);

        // Restore the previous active reminder where possible.
        if (previous != null && previous.enabled) {
          final previousNext = previous.nextOccurrence();

          if (previousNext.isAfter(DateTime.now())) {
            await _scheduler.scheduleWithOptions(
              plantId: previous.plantId,
              plantName: previous.plantName,
              reminderTime: previousNext,
              repeatDays: previous.repeatDays,
            );
          }
        }

        rethrow;
      }

      if (!mounted) return;

      setState(() {
        _saved = settings;
        _time = next;
      });

      _message('${settings.frequencyLabel} watering reminder scheduled.');
    } catch (error) {
      if (!mounted) return;

      _message('Could not enable reminder: $error');
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disable() async {
    setState(() => _busy = true);

    try {
      final service = WateringReminderService(scheduler: _scheduler);
      await service.disableReminder(plantId: widget.plantId);

      final settings = WateringReminderSettings(
        plantId: widget.plantId,
        plantName: widget.plantName,
        reminderTime: _saved?.reminderTime ?? _time,
        repeatDays: _saved?.repeatDays ?? _repeatDays,
        enabled: false,
      );

      if (mounted) setState(() => _saved = settings);

      try {
        await _storage.save(settings);
      } catch (_) {
        throw StateError(
          'Notification cancelled, but settings could not be saved. '
          'Please retry disabling.',
        );
      }

      _message('Watering reminder disabled.');
    } catch (error) {
      _message('Could not finish disabling: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
    final nextSaved = saved?.nextOccurrence();

    final active = saved != null &&
        saved.enabled &&
        nextSaved != null &&
        nextSaved.isAfter(DateTime.now());

    final preview = _draft().nextOccurrence();

    return Scaffold(
      appBar: AppBar(title: const Text('Watering Reminder')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Icon(
                      Icons.water_drop,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.plantName,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      active
                          ? 'Next reminder: ${_format(nextSaved)}'
                          : 'No upcoming reminder',
                    ),
                    if (active) ...[
                      const SizedBox(height: 6),
                      Text('Frequency: ${saved.frequencyLabel}'),
                    ],
                    const SizedBox(height: 24),
                    DropdownButtonFormField<int>(
                      key: ValueKey('frequency-$_repeatDays'),
                      initialValue: _repeatDays,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Once'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Daily'),
                        ),
                        DropdownMenuItem(
                          value: 7,
                          child: Text('Weekly'),
                        ),
                      ],
                      onChanged: _busy
                          ? null
                          : (value) {
                              if (value == null) return;
                              setState(() => _repeatDays = value);
                            },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _repeatDays == 1
                            ? 'Reminder time'
                            : _repeatDays == 7
                                ? 'Choose weekday and time'
                                : 'Reminder date and time',
                      ),
                      subtitle: Text(_format(preview)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _busy ? null : _chooseTime,
                    ),
                    if (_repeatDays != 0)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Repeats begin at the next matching time. '
                          'Weekly reminders use the weekday of your chosen date.',
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _busy ? null : _enable,
                      icon: const Icon(Icons.notifications_active),
                      label: Text(
                        active ? 'Update Reminder' : 'Enable Reminder',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _disable,
                      icon: const Icon(Icons.notifications_off),
                      label: const Text('Disable Reminder'),
                    ),
                    if (_busy)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
    );
  }
}