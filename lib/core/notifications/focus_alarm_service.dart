import 'notification_service.dart';

class FocusAlarmService {
  const FocusAlarmService(this._notifications);

  static const channelId = 'focus_alarms';
  static const notificationId = 9001;

  final NotificationScheduler _notifications;

  Future<void> scheduleCompletion({
    required DateTime endAt,
    String? taskTitle,
  }) {
    return _notifications.schedule(
      ScheduledNotification(
        id: notificationId,
        channelId: channelId,
        title: 'Focus Complete',
        body: taskTitle == null ? 'Your focus timer is complete.' : '$taskTitle focus timer is complete.',
        scheduledAt: endAt,
      ),
    );
  }

  Future<void> cancelCompletion() {
    return _notifications.cancel(notificationId);
  }
}
