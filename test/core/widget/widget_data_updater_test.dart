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
  final updatedWidgets = <String?>[];

  setUp(() {
    db = AppDatabase.memory();
    repository = TaskRepository(db);
    savedData.clear();
    updatedWidgets.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'saveWidgetData') {
            final args = methodCall.arguments as Map<dynamic, dynamic>;
            savedData[args['id'] as String] = args['data'];
            return true;
          } else if (methodCall.method == 'updateWidget') {
            final args = methodCall.arguments as Map<dynamic, dynamic>;
            updatedWidgets.add(args['android'] as String?);
            return true;
          }
          return null;
        });
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'WidgetDataUpdater stores checklist rows for the Today widget',
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
      expect(savedData['widget_task1_id'], isNotEmpty);
      expect(savedData['widget_task1_title'], 'Review notes');
      expect(savedData['widget_task1_time'], '');
      expect(savedData['widget_task2_id'], isNotEmpty);
      expect(savedData['widget_task2_title'], 'Plan sprint');
      expect(savedData['widget_task2_time'], '9:00');
      expect(savedData['widget_task3_id'], isNotEmpty);
      expect(savedData['widget_task3_title'], 'Send update');
      expect(savedData['widget_task3_time'], '');
      expect(savedData['widget_more_count'], '0');
      expect(savedData['widget_more_text'], '');
      expect(updatedWidgets, containsAll(WidgetDataUpdater.androidWidgetNames));
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
      expect(updatedWidgets, containsAll(WidgetDataUpdater.androidWidgetNames));
    },
  );

  test(
    'WidgetDataUpdater stores six checklist rows before overflow summary',
    () async {
      final now = DateTime.now();
      for (var i = 1; i <= 8; i++) {
        await repository.createTask(
          TaskDraft(title: 'Task $i', scheduledDate: now),
        );
      }

      await WidgetDataUpdater.update(repository);

      expect(savedData['widget_tasks_count'], '8');
      expect(savedData['widget_today_header'], 'Today, 8 tasks left');
      for (var i = 1; i <= 6; i++) {
        expect(savedData['widget_task${i}_title'], 'Task $i');
      }
      expect(savedData['widget_more_count'], '2');
      expect(savedData['widget_more_text'], '+2 more today');
      expect(updatedWidgets, containsAll(WidgetDataUpdater.androidWidgetNames));
    },
  );

  test('WidgetDataUpdater handles 0 tasks left gracefully', () async {
    await WidgetDataUpdater.update(repository);

    expect(savedData['widget_tasks_count'], '0');
    expect(savedData['widget_tasks_count_text'], '0 tasks left');
    expect(savedData['widget_today_header'], 'Today, 0 tasks left');
    expect(savedData['widget_task1_title'], '');
    expect(savedData['widget_task1_id'], '');
    expect(savedData['widget_task2_title'], '');
    expect(savedData['widget_task2_id'], '');
    expect(savedData['widget_task3_title'], '');
    expect(savedData['widget_task3_id'], '');
    expect(savedData['widget_more_count'], '0');
    expect(savedData['widget_more_text'], '');
    expect(updatedWidgets, containsAll(WidgetDataUpdater.androidWidgetNames));
  });

  test(
    'WidgetDataUpdater stores progress text with completed today count',
    () async {
      final now = DateTime.now();
      final completedId = await repository.createTask(
        TaskDraft(title: 'Done', scheduledDate: now),
      );
      await repository.completeTask(completedId);
      await repository.createTask(TaskDraft(title: 'Todo', scheduledDate: now));

      await WidgetDataUpdater.update(repository);

      expect(savedData['widget_tasks_completed_count'], '1');
      expect(savedData['widget_tasks_total_count'], '2');
      expect(savedData['widget_progress_text'], '1/2');
      expect(savedData['widget_progress_subtext'], '1 done today');
    },
  );
}
