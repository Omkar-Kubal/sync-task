import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationScheduler>((ref) {
  return NotificationService();
});

final taskReminderServiceProvider = Provider<TaskReminderService>((ref) {
  return TaskReminderService(ref.watch(notificationServiceProvider));
});

class TaskReminderService {
  const TaskReminderService(this._notifications);

  static const channelId = 'task_reminders';

  final NotificationScheduler _notifications;

  Future<void> reconcileTask({
    required int taskId,
    required String title,
    required DateTime? reminderTime,
    required bool isCompleted,
  }) async {
    if (reminderTime == null || isCompleted) {
      await cancelTask(taskId);
      return;
    }

    await _notifications.schedule(
      ScheduledNotification(
        id: taskId,
        channelId: channelId,
        title: 'Task Reminder',
        body: title,
        scheduledAt: reminderTime,
      ),
    );
  }

  Future<void> cancelTask(int taskId) {
    return _notifications.cancel(taskId);
  }
}


