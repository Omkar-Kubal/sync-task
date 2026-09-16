import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'completed local day query uses completedAt instead of schedule date',
    () async {
      final repository = TaskRepository(db);
      final targetDay = DateTime(2026, 9, 9);
      final previousDay = DateTime(2026, 9, 8);

      final overdue = await repository.createTask(
        domain.TaskDraft(title: 'Finished overdue', scheduledDate: previousDay),
      );
      await TaskRepository(
        db,
        now: () => DateTime(2026, 9, 9, 10),
      ).completeTask(overdue);

      final scheduledToday = await repository.createTask(
        domain.TaskDraft(title: 'Finished tomorrow', scheduledDate: targetDay),
      );
      await TaskRepository(
        db,
        now: () => DateTime(2026, 9, 10, 10),
      ).completeTask(scheduledToday);

      final activeToday = await repository.createTask(
        domain.TaskDraft(title: 'Still active today', scheduledDate: targetDay),
      );
      expect(await repository.getTask(activeToday), isNotNull);

      final tasks = await repository.listCompletedTasksForLocalDay(targetDay);

      expect(tasks.map((task) => task.title), ['Finished overdue']);
    },
  );

  test(
    'completed range query includes start excludes end and ignores active tasks',
    () async {
      final repository = TaskRepository(db);
      final atStart = await repository.createTask(
        const domain.TaskDraft(title: 'At start'),
      );
      await TaskRepository(
        db,
        now: () => DateTime(2026, 9, 8),
      ).completeTask(atStart);

      final inside = await repository.createTask(
        const domain.TaskDraft(title: 'Inside range'),
      );
      await TaskRepository(
        db,
        now: () => DateTime(2026, 9, 9, 12),
      ).completeTask(inside);

      final atEnd = await repository.createTask(
        const domain.TaskDraft(title: 'At end'),
      );
      await TaskRepository(
        db,
        now: () => DateTime(2026, 9, 15),
      ).completeTask(atEnd);

      await repository.createTask(const domain.TaskDraft(title: 'Active'));

      final tasks = await repository.listCompletedTasksInRange(
        DateTime(2026, 9, 8),
        DateTime(2026, 9, 15),
      );

      expect(tasks.map((task) => task.title), ['At start', 'Inside range']);
    },
  );
}
