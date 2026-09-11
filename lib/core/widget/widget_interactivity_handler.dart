import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/tasks/data/task_repository.dart';
import '../../features/tasks/domain/task.dart';
import '../database/app_database.dart';
import 'widget_data_updater.dart';

typedef WidgetRefresh = Future<void> Function(TaskRepository repository);

Future<void> registerWidgetInteractivityCallback() {
  return HomeWidget.registerInteractivityCallback(
    widgetInteractivityCallback,
  ).then((_) {});
}

@pragma('vm:entry-point')
Future<void> widgetInteractivityCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final database = AppDatabase();
  try {
    await handleWidgetInteractivity(uri, repository: TaskRepository(database));
  } finally {
    await database.close();
  }
}

Future<void> handleWidgetInteractivity(
  Uri? uri, {
  required TaskRepository repository,
  WidgetRefresh refreshWidgets = WidgetDataUpdater.update,
}) async {
  if (uri == null || uri.scheme != 'synctasks') return;
  if (uri.host != 'complete-task' && uri.host != 'toggle-task') return;

  final taskId = int.tryParse(uri.queryParameters['taskId'] ?? '');
  if (taskId == null) return;

  if (uri.host == 'toggle-task') {
    final task = await repository.getTask(taskId);
    if (task == null) return;
    if (task.isCompleted) {
      await repository.restoreTask(TaskSnapshot(taskId: taskId));
    } else {
      await repository.completeTask(taskId);
    }
  } else {
    await repository.completeTask(taskId);
  }
  await refreshWidgets(repository);
}
