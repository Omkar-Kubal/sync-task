import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.channelId,
    required this.title,
    required this.body,
    required this.scheduledAt,
  });

  final int id;
  final String channelId;
  final String title;
  final String body;
  final DateTime scheduledAt;
}

abstract interface class NotificationScheduler {
  Future<void> schedule(ScheduledNotification notification);

  Future<void> cancel(int id);
}

abstract interface class LocalNotificationsPlugin {
  Future<void> initialize(InitializationSettings settings);

  Future<void> requestAndroidNotificationPermission();

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required NotificationDetails details,
  });

  Future<void> cancel(int id);
}

class PluginScheduledNotification {
  const PluginScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.details,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final NotificationDetails details;
}

class RecordingNotificationScheduler implements NotificationScheduler {
  final scheduled = <ScheduledNotification>[];
  final cancelled = <int>[];

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    scheduled.add(notification);
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
  }
}

class NotificationService implements NotificationScheduler {
  NotificationService({LocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsAdapter();

  final LocalNotificationsPlugin _plugin;
  var _initialized = false;
  var _notificationPermissionRequested = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    await _setLocalTimezone();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    await initialize();
    await _requestAndroidNotificationPermission();
    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      scheduledAt: notification.scheduledAt,
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          notification.channelId,
          _channelName(notification.channelId),
          channelDescription: _channelDescription(notification.channelId),
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _requestAndroidNotificationPermission() async {
    if (_notificationPermissionRequested) {
      return;
    }
    await _plugin.requestAndroidNotificationPermission();
    _notificationPermissionRequested = true;
  }

  @override
  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  Future<void> _setLocalTimezone() async {
    if (kIsWeb) {
      return;
    }

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } on Object {
      tz.setLocalLocation(tz.UTC);
    }
  }

  String _channelName(String channelId) {
    return switch (channelId) {
      'task_reminders' => 'Task reminders',
      _ => 'SyncTasks notifications',
    };
  }

  String _channelDescription(String channelId) {
    return switch (channelId) {
      'task_reminders' => 'Scheduled task reminder alerts.',
      _ => 'SyncTasks scheduled alerts.',
    };
  }
}

class FlutterLocalNotificationsAdapter implements LocalNotificationsPlugin {
  FlutterLocalNotificationsAdapter({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize(InitializationSettings settings) async {
    await _plugin.initialize(settings: settings);
  }

  @override
  Future<void> requestAndroidNotificationPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required NotificationDetails details,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) {
    return _plugin.cancel(id: id);
  }
}
