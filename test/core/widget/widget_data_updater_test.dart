import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/widget/widget_data_updater.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TaskRepository repository;
  final savedData = <String, dynamic>{};
  var updateWidgetCalled = false;

  setUp(() {
    db = AppDatabase.memory();
    repository = TaskRepository(db);
    savedData.clear();
    updateWidgetCalled = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'saveWidgetData') {
            final args = methodCall.arguments as Map<dynamic, dynamic>;
            savedData[args['id'] as String] = args['data'];
            return true;
          } else if (methodCall.method == 'updateWidget') {
            updateWidgetCalled = true;
            return true;
          }
          return null;
        });
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'WidgetDataUpdater formats overflow task counts as one row plus summary',
    () async {
      final now = DateTime.now();
      await repository.createTask(
        TaskDraft(title: 'Review notes', scheduledDate: now),
      );
      await repository.createTask(
        TaskDraft(
          title: 'Plan sprint',
          scheduledDate: now,
          scheduledTime: DateTime(now.year, now.month, now.day, 9, 0),
        ),
      );
      await repository.createTask(
        TaskDraft(title: 'Send update', scheduledDate: now),
      );

      await WidgetDataUpdater.update(repository);

      expect(savedData['widget_tasks_count'], '3');
      expect(savedData['widget_tasks_count_text'], '3 tasks left');
      expect(savedData['widget_today_header'], 'Today, 3 tasks left');
      expect(savedData['widget_task1_title'], 'Review notes');
      expect(savedData['widget_task1_time'], '');
      expect(savedData['widget_task2_title'], '');
      expect(savedData['widget_task2_time'], '');
      expect(savedData['widget_task3_title'], '');
      expect(savedData['widget_task3_time'], '');
      expect(savedData['widget_more_count'], '2');
      expect(savedData['widget_more_text'], '+2 more today');
      expect(updateWidgetCalled, isTrue);
    },
  );

  test(
    'WidgetDataUpdater keeps two visible rows for exactly two tasks',
    () async {
      final now = DateTime.now();
      await repository.createTask(
        TaskDraft(title: 'Task 1', scheduledDate: now),
      );
      await repository.createTask(
        TaskDraft(title: 'Task 2', scheduledDate: now),
      );

      await WidgetDataUpdater.update(repository);

      expect(savedData['widget_tasks_count'], '2');
      expect(savedData['widget_today_header'], 'Today, 2 tasks left');
      expect(savedData['widget_task1_title'], 'Task 1');
      expect(savedData['widget_task2_title'], 'Task 2');
      expect(savedData['widget_task3_title'], '');
      expect(savedData['widget_more_count'], '0');
      expect(savedData['widget_more_text'], '');
      expect(updateWidgetCalled, isTrue);
    },
  );

  test(
    'WidgetDataUpdater summarizes larger task counts without extra rows',
    () async {
      final now = DateTime.now();
      for (var i = 1; i <= 5; i++) {
        await repository.createTask(
          TaskDraft(title: 'Task $i', scheduledDate: now),
        );
      }

      await WidgetDataUpdater.update(repository);

      expect(savedData['widget_tasks_count'], '5');
      expect(savedData['widget_today_header'], 'Today, 5 tasks left');
      expect(savedData['widget_task1_title'], 'Task 1');
      expect(savedData['widget_task2_title'], '');
      expect(savedData['widget_task3_title'], '');
      expect(savedData['widget_more_count'], '4');
      expect(savedData['widget_more_text'], '+4 more today');
      expect(updateWidgetCalled, isTrue);
    },
  );

  test('WidgetDataUpdater handles 0 tasks left gracefully', () async {
    await WidgetDataUpdater.update(repository);

    expect(savedData['widget_tasks_count'], '0');
    expect(savedData['widget_tasks_count_text'], '0 tasks left');
    expect(savedData['widget_today_header'], 'Today, 0 tasks left');
    expect(savedData['widget_task1_title'], '');
    expect(savedData['widget_task2_title'], '');
    expect(savedData['widget_task3_title'], '');
    expect(savedData['widget_more_count'], '0');
    expect(savedData['widget_more_text'], '');
    expect(updateWidgetCalled, isTrue);
  });
}


