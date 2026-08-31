import 'recurrence_type.dart';

class TaskSeriesDraft {
  const TaskSeriesDraft({
    required this.title,
    required this.folderId,
    required this.repeatType,
    required this.anchorDate,
    this.time,
    this.reminderTime,
    this.focusDurationMinutes,
  });

  final String title;
  final int folderId;
  final RecurrenceType repeatType;
  final DateTime anchorDate;
  final DateTime? time;
  final DateTime? reminderTime;
  final int? focusDurationMinutes;
}
