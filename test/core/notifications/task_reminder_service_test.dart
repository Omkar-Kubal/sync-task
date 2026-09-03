import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/notifications/notification_service.dart';
import 'package:synctask/core/notifications/task_reminder_service.dart';

void main() {
  test('task reminder service schedules and cancels task reminders', () async {
    final notifications = RecordingNotificationScheduler();
    final service = TaskReminderService(notifications);
    final reminderAt = DateTime(2026, 9, 1, 9);

    await service.reconcileTask(
      taskId: 42,
      title: 'Write report',
      reminderTime: reminderAt,
      isCompleted: false,
    );
    await service.cancelTask(42);

    expect(
      notifications.scheduled.single.channelId,
      TaskReminderService.channelId,
    );
    expect(notifications.scheduled.single.id, 42);
    expect(notifications.scheduled.single.scheduledAt, reminderAt);
    expect(notifications.cancelled.single, 42);
  });

  test('completed tasks cancel instead of scheduling reminders', () async {
    final notifications = RecordingNotificationScheduler();
    final service = TaskReminderService(notifications);

    await service.reconcileTask(
      taskId: 42,
      title: 'Write report',
      reminderTime: DateTime(2026, 9, 1, 9),
      isCompleted: true,
    );

    expect(notifications.scheduled, isEmpty);
    expect(notifications.cancelled.single, 42);
  });
}
