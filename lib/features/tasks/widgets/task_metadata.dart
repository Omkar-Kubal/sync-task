import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../domain/recurrence_type.dart';

String? taskMetadataFor(
  Task task, {
  Map<int, String> folderNamesById = const {},
  TaskSery? series,
  bool includeDate = true,
}) {
  final parts = <String>[];
  final folderName = folderNamesById[task.folderId];
  if (folderName != null && folderName.isNotEmpty) {
    parts.add(folderName);
  }
  if (includeDate && task.scheduledDate != null) {
    parts.add(DateFormat('MMM d').format(task.scheduledDate!));
  }
  if (task.scheduledTime != null) {
    parts.add(DateFormat('h:mm a').format(task.scheduledTime!));
  }
  if (task.reminderTime != null) {
    parts.add('Reminder ${DateFormat('h:mm a').format(task.reminderTime!)}');
  }
  final repeat = _repeatLabel(task, series);
  if (repeat != null) {
    parts.add(repeat);
  }
  return parts.isEmpty ? null : parts.join(' · ');
}

String? _repeatLabel(Task task, TaskSery? series) {
  if (series != null) {
    if (series.customRepeatLabel != null &&
        series.customRepeatLabel!.isNotEmpty) {
      return series.customRepeatLabel;
    }
    return switch (RecurrenceType.fromStorage(series.repeatType)) {
      RecurrenceType.daily => 'Daily',
      RecurrenceType.weekly => 'Weekly',
      RecurrenceType.monthly => 'Monthly',
    };
  }
  return task.seriesId == null ? null : 'Repeats';
}


