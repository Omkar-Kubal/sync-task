import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/notifications/notification_service.dart';

void main() {
  test(
    'notification service initializes plugin without requesting Android permission',
    () async {
      final plugin = FakeLocalNotificationsPlugin();
      final service = NotificationService(plugin: plugin);

      await service.initialize();

      expect(plugin.initialized, isTrue);
      expect(plugin.requestedNotificationPermission, isFalse);
    },
  );

  test(
    'notification service schedules Android notification through plugin',
    () async {
      final plugin = FakeLocalNotificationsPlugin();
      final service = NotificationService(plugin: plugin);
      final scheduledAt = DateTime(2026, 9, 1, 9);

      await service.schedule(
        ScheduledNotification(
          id: 42,
          channelId: 'task_reminders',
          title: 'Task Reminder',
          body: 'Write report',
          scheduledAt: scheduledAt,
        ),
      );

      expect(plugin.scheduled.single.id, 42);
      expect(plugin.scheduled.single.title, 'Task Reminder');
      expect(plugin.scheduled.single.body, 'Write report');
      expect(
        plugin.scheduled.single.details.android?.channelId,
        'task_reminders',
      );
      expect(
        plugin.scheduled.single.details.android?.channelName,
        'Task reminders',
      );
      expect(plugin.requestedNotificationPermission, isTrue);
    },
  );

  test('notification service cancels notification through plugin', () async {
    final plugin = FakeLocalNotificationsPlugin();
    final service = NotificationService(plugin: plugin);

    await service.cancel(42);

    expect(plugin.cancelled.single, 42);
  });
}

class FakeLocalNotificationsPlugin implements LocalNotificationsPlugin {
  var initialized = false;
  var requestedNotificationPermission = false;
  final scheduled = <PluginScheduledNotification>[];
  final cancelled = <int>[];

  @override
  Future<void> initialize(InitializationSettings settings) async {
    initialized = true;
  }

  @override
  Future<void> requestAndroidNotificationPermission() async {
    requestedNotificationPermission = true;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required NotificationDetails details,
  }) async {
    scheduled.add(
      PluginScheduledNotification(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        details: details,
      ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
  }
}
