import 'recurrence_type.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    this.folderId,
    this.scheduledDate,
    this.scheduledTime,
    this.reminderTime,
    this.focusDurationMinutes,
    this.recurrenceType,
    this.recurrenceInterval,
    this.customRepeatLabel,
  });

  final String title;
  final int? folderId;
  final DateTime? scheduledDate;
  final DateTime? scheduledTime;
  final DateTime? reminderTime;
  final int? focusDurationMinutes;
  final RecurrenceType? recurrenceType;
  final int? recurrenceInterval;
  final String? customRepeatLabel;
}

class TaskSnapshot {
  const TaskSnapshot({required this.taskId, this.generatedSuccessorId});

  final int taskId;
  final int? generatedSuccessorId;
}


