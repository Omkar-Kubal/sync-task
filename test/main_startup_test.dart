import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synctasks/app.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart';
import 'package:synctasks/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startup shares the app database with the widget refresh', () async {
    SharedPreferences.setMockInitialValues({});
    AppDatabase? capturedDatabase;
    final widgetRefreshCompleted = Completer<void>();

    await runSyncTasksApp(
      getSharedPreferences: SharedPreferences.getInstance,
      initializeNotifications: () async {},
      registerWidgetInteractivity: () async {},
      createDatabase: AppDatabase.memory,
      updateWidgetData: (repository) async {
        await repository.createTask(
          TaskDraft(
            title: 'Startup shared database',
            scheduledDate: DateTime.now(),
          ),
        );
        widgetRefreshCompleted.complete();
      },
      appRunner: (widget) {
        final app = widget as SyncTasksApp;
        capturedDatabase = app.appDatabase;
      },
    );
    await widgetRefreshCompleted.future;

    final database = capturedDatabase;
    expect(database, isNotNull);
    addTearDown(database!.close);

    final tasks = await TaskRepository(database).listAllActiveTasks();
    expect(tasks.single.title, 'Startup shared database');
  });

  test('startup registers widget interactivity callbacks', () async {
    SharedPreferences.setMockInitialValues({});
    var registered = false;
    AppDatabase? capturedDatabase;

    await runSyncTasksApp(
      getSharedPreferences: SharedPreferences.getInstance,
      initializeNotifications: () async {},
      registerWidgetInteractivity: () async {
        registered = true;
      },
      createDatabase: AppDatabase.memory,
      updateWidgetData: (_) async {},
      appRunner: (widget) {
        final app = widget as SyncTasksApp;
        capturedDatabase = app.appDatabase;
      },
    );
    addTearDown(capturedDatabase!.close);

    expect(registered, isTrue);
  });
}
