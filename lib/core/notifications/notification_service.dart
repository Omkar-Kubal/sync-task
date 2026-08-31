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
  @override
  Future<void> schedule(ScheduledNotification notification) async {
    // Android plugin integration is added behind this interface.
  }

  @override
  Future<void> cancel(int id) async {
    // Android plugin integration is added behind this interface.
  }
}
