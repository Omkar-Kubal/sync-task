import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/crash/crash_reporter.dart';
import 'core/database/app_database.dart';
import 'core/widget/widget_data_updater.dart';
import 'core/widget/widget_interactivity_handler.dart';
import 'features/tasks/data/task_repository.dart';

Future<void> main() => CrashReporter.runAppGuarded(runSyncTasksApp);

@visibleForTesting
Future<void> runSyncTasksApp({
  Future<SharedPreferences> Function() getSharedPreferences =
      SharedPreferences.getInstance,
  Future<void> Function()? initializeNotifications,
  Future<void> Function() registerWidgetInteractivity =
      registerWidgetInteractivityCallback,
  AppDatabase Function() createDatabase = AppDatabase.new,
  Future<void> Function(TaskRepository repository) updateWidgetData =
      _updateWidgetData,
  void Function(Widget widget) appRunner = runApp,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await getSharedPreferences();
  final database = createDatabase();

  CrashReporter.unawaitedCapture(
    registerWidgetInteractivity(),
    hint: 'Widget interactivity registration failed',
  );
  CrashReporter.unawaitedCapture(
    updateWidgetData(TaskRepository(database)),
    hint: 'Widget data update failed',
  );

  appRunner(
    SyncTasksApp(sharedPreferences: sharedPreferences, appDatabase: database),
  );
}

Future<void> _updateWidgetData(TaskRepository repository) =>
    WidgetDataUpdater.update(repository);
