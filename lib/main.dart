import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/crash/crash_reporter.dart';
import 'core/database/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'core/widget/widget_data_updater.dart';
import 'features/tasks/data/task_repository.dart';

Future<void> main() => CrashReporter.runAppGuarded(runSyncTasksApp);

@visibleForTesting
Future<void> runSyncTasksApp({
  Future<SharedPreferences> Function() getSharedPreferences =
      SharedPreferences.getInstance,
  Future<void> Function() initializeNotifications = _initializeNotifications,
  Future<void> Function() updateWidgetData = _updateWidgetData,
  void Function(Widget widget) appRunner = runApp,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await getSharedPreferences();

  CrashReporter.unawaitedCapture(
    initializeNotifications(),
    hint: 'Notification initialization failed',
  );
  CrashReporter.unawaitedCapture(
    updateWidgetData(),
    hint: 'Widget data update failed',
  );

  appRunner(SyncTasksApp(sharedPreferences: sharedPreferences));
}

Future<void> _initializeNotifications() => NotificationService().initialize();

Future<void> _updateWidgetData() async {
  final db = AppDatabase();
  try {
    await WidgetDataUpdater.update(TaskRepository(db));
  } finally {
    await db.close();
  }
}


