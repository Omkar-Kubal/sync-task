import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/notifications/focus_alarm_service.dart';
import 'package:synctask/core/notifications/notification_service.dart';

void main() {
  test(
    'focus alarm service schedules and cancels completion alarms separately',
    () async {
      final notifications = RecordingNotificationScheduler();
      final service = FocusAlarmService(notifications);
      final endAt = DateTime(2026, 9, 1, 10, 25);

      await service.scheduleCompletion(endAt: endAt, taskTitle: 'Study');
      await service.cancelCompletion();

      expect(
        notifications.scheduled.single.channelId,
        FocusAlarmService.channelId,
      );
      expect(notifications.scheduled.single.title, 'Focus Complete');
      expect(notifications.scheduled.single.body, contains('Study'));
      expect(notifications.cancelled.single, FocusAlarmService.notificationId);
    },
  );
}
