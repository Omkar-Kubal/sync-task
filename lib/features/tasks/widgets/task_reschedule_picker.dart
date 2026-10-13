import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class TaskRescheduleSelection {
  const TaskRescheduleSelection({
    required this.date,
    required this.time,
    required this.reminderTime,
    required this.reminderRemoved,
  });

  final DateTime date;
  final DateTime? time;
  final DateTime? reminderTime;
  final bool reminderRemoved;
}

Future<TaskRescheduleSelection?> showTaskReschedulePicker(
  BuildContext context,
  Task task, {
  DateTime? now,
}) async {
  final currentTime = now == null ? DateTime.now : () => now;
  final initialNow = currentTime();
  final today = _dateOnly(initialNow);
  final taskDate = task.scheduledDate == null
      ? today
      : _dateOnly(task.scheduledDate!);
  final initialDate = taskDate.isBefore(today) ? today : taskDate;
  final selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: today,
    lastDate: DateTime(today.year + 5, 12, 31),
  );
  if (selectedDate == null || !context.mounted) {
    return null;
  }

  final date = _dateOnly(selectedDate);
  DateTime? selectedTime;
  if (task.scheduledTime != null) {
    selectedTime = DateTime(
      date.year,
      date.month,
      date.day,
      task.scheduledTime!.hour,
      task.scheduledTime!.minute,
    );
    if (date == today && !selectedTime.isAfter(_currentMinute(currentTime()))) {
      selectedTime = await _pickFutureTime(context, date, currentTime);
      if (selectedTime == null || !context.mounted) {
        return null;
      }
    }
  }

  DateTime? reminderTime;
  var reminderRemoved = false;
  if (task.reminderTime != null) {
    final existingReminder = task.reminderTime!;
    final oldScheduledDate = task.scheduledDate == null
        ? null
        : _dateOnly(task.scheduledDate!);
    final oldDue = oldScheduledDate == null
        ? null
        : DateTime(
            oldScheduledDate.year,
            oldScheduledDate.month,
            oldScheduledDate.day,
            task.scheduledTime?.hour ?? 0,
            task.scheduledTime?.minute ?? 0,
          );
    final newDue = DateTime(
      date.year,
      date.month,
      date.day,
      selectedTime?.hour ?? 0,
      selectedTime?.minute ?? 0,
    );
    reminderTime = oldDue == null
        ? DateTime(
            date.year,
            date.month,
            date.day,
            existingReminder.hour,
            existingReminder.minute,
          )
        : newDue.add(existingReminder.difference(oldDue));
    if (reminderTime.isBefore(currentTime())) {
      reminderTime = null;
      reminderRemoved = true;
    }
  }

  return TaskRescheduleSelection(
    date: date,
    time: selectedTime,
    reminderTime: reminderTime,
    reminderRemoved: reminderRemoved,
  );
}

Future<DateTime?> _pickFutureTime(
  BuildContext context,
  DateTime date,
  DateTime Function() currentTime,
) async {
  while (context.mounted) {
    final now = currentTime();
    final nextMinute = _currentMinute(now).add(const Duration(minutes: 1));
    final initialTime = TimeOfDay.fromDateTime(nextMinute);
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Choose a future time',
    );
    if (selectedTime == null || !context.mounted) {
      return null;
    }

    final candidate = DateTime(
      date.year,
      date.month,
      date.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (candidate.isAfter(_currentMinute(currentTime()))) {
      return candidate;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Choose a time later than now.')),
    );
  }
  return null;
}

DateTime _currentMinute(DateTime value) =>
    DateTime(value.year, value.month, value.day, value.hour, value.minute);

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
