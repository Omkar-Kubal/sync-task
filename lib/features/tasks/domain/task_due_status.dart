enum TaskDueStatus { completed, overdue, today, upcoming, unscheduled }

TaskDueStatus taskDueStatus({
  required bool isCompleted,
  required DateTime? scheduledDate,
  required DateTime? scheduledTime,
  required DateTime now,
}) {
  if (isCompleted) {
    return TaskDueStatus.completed;
  }
  if (scheduledDate == null) {
    return TaskDueStatus.unscheduled;
  }

  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(
    scheduledDate.year,
    scheduledDate.month,
    scheduledDate.day,
  );
  if (date.isBefore(today)) {
    return TaskDueStatus.overdue;
  }
  if (date.isAfter(today)) {
    return TaskDueStatus.upcoming;
  }
  if (scheduledTime == null) {
    return TaskDueStatus.today;
  }

  final dueMinute = DateTime(
    date.year,
    date.month,
    date.day,
    scheduledTime.hour,
    scheduledTime.minute,
  );
  final currentMinute = DateTime(
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
  );
  return dueMinute.isBefore(currentMinute)
      ? TaskDueStatus.overdue
      : TaskDueStatus.today;
}
