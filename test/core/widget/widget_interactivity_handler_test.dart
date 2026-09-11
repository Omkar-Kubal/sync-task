import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/widget/widget_interactivity_handler.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repository;
  var refreshed = false;

  setUp(() {
    db = AppDatabase.memory();
    repository = TaskRepository(db);
    refreshed = false;
  });

  tearDown(() async {
    await db.close();
  });

  test('completes a widget task action without opening the app', () async {
    final taskId = await repository.createTask(
      TaskDraft(title: 'Finish from widget', scheduledDate: DateTime.now()),
    );

    await handleWidgetInteractivity(
      Uri.parse('synctasks://complete-task?taskId=$taskId'),
      repository: repository,
      refreshWidgets: (_) async {
        refreshed = true;
      },
    );

    final active = await repository.listTodayTasks();
    final completed = await repository.listCompletedTasksForLocalDay(
      DateTime.now(),
    );

    expect(active, isEmpty);
    expect(completed.single.id, taskId);
    expect(refreshed, isTrue);
  });

  test('restores a completed task when a toggle action targets it', () async {
    final taskId = await repository.createTask(
      TaskDraft(title: 'Restore from widget', scheduledDate: DateTime.now()),
    );
    await repository.completeTask(taskId);

    await handleWidgetInteractivity(
      Uri.parse('synctasks://toggle-task?taskId=$taskId'),
      repository: repository,
      refreshWidgets: (_) async {
        refreshed = true;
      },
    );

    final active = await repository.listTodayTasks();
    final completed = await repository.listCompletedTasksForLocalDay(
      DateTime.now(),
    );

    expect(active.single.id, taskId);
    expect(completed, isEmpty);
    expect(refreshed, isTrue);
  });

  test('ignores malformed widget actions', () async {
    final taskId = await repository.createTask(
      TaskDraft(title: 'Keep me active', scheduledDate: DateTime.now()),
    );

    await handleWidgetInteractivity(
      Uri.parse('synctasks://complete-task'),
      repository: repository,
      refreshWidgets: (_) async {
        refreshed = true;
      },
    );

    final active = await repository.listTodayTasks();
    expect(active.single.id, taskId);
    expect(refreshed, isFalse);
  });
}
