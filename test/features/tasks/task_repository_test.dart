import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/recurrence_type.dart';
import 'package:synctasks/features/tasks/domain/task.dart';

void main() {
  late AppDatabase db;
  late TaskRepository tasks;
  late FolderRepository folders;

  final now = DateTime(2026, 8, 31, 9);

  setUp(() {
    db = AppDatabase.memory();
    tasks = TaskRepository(db, now: () => now);
    folders = FolderRepository(db, now: () => now);
  });

  tearDown(() async {
    await db.close();
  });

  test('creates no-date task in Inbox', () async {
    await tasks.createTask(const TaskDraft(title: 'Capture idea'));

    final inbox = await folders.inbox();
    final inboxTasks = await tasks.listFolderTasks(inbox.id);

    expect(inboxTasks.single.title, 'Capture idea');
    expect(inboxTasks.single.folderId, inbox.id);
    expect(inboxTasks.single.scheduledDate, isNull);
  });

  test('queries today upcoming and completed tasks', () async {
    final todayId = await tasks.createTask(
      TaskDraft(title: 'Today task', scheduledDate: DateTime(2026, 8, 31)),
    );
    await tasks.createTask(
      TaskDraft(title: 'Future task', scheduledDate: DateTime(2026, 9, 2)),
    );
    await tasks.completeTask(todayId);

    expect((await tasks.listTodayTasks()), isEmpty);
    expect((await tasks.listUpcomingTasks()).single.title, 'Future task');
    expect((await tasks.listCompletedTasks()).single.title, 'Today task');
  });

  test('all active tasks excludes completed tasks', () async {
    await tasks.createTask(const TaskDraft(title: 'Active no date'));
    final completedId = await tasks.createTask(
      TaskDraft(title: 'Completed today', scheduledDate: DateTime(2026, 8, 31)),
    );
    await tasks.completeTask(completedId);

    final active = await tasks.listAllActiveTasks();

    expect(active.map((task) => task.title), ['Active no date']);
  });

  test('reminder tasks includes only active tasks with reminders', () async {
    await tasks.createTask(
      TaskDraft(
        title: 'Remind me',
        scheduledDate: DateTime(2026, 8, 31),
        reminderTime: DateTime(2026, 8, 31, 8),
      ),
    );
    await tasks.createTask(const TaskDraft(title: 'No reminder'));
    final completedReminderId = await tasks.createTask(
      TaskDraft(
        title: 'Completed reminder',
        scheduledDate: DateTime(2026, 8, 31),
        reminderTime: DateTime(2026, 8, 31, 7),
      ),
    );
    await tasks.completeTask(completedReminderId);

    final reminders = await tasks.listReminderTasks();

    expect(reminders.map((task) => task.title), ['Remind me']);
  });

  test('upcoming includes active tasks scheduled for today', () async {
    await tasks.createTask(
      TaskDraft(title: 'Today task', scheduledDate: DateTime(2026, 8, 31)),
    );
    await tasks.createTask(
      TaskDraft(title: 'Future task', scheduledDate: DateTime(2026, 9, 2)),
    );

    final upcoming = await tasks.listUpcomingTasks();

    expect(upcoming.map((task) => task.title), ['Today task', 'Future task']);
  });

  test('updates an existing task title', () async {
    final taskId = await tasks.createTask(
      TaskDraft(title: 'Draft title', scheduledDate: DateTime(2026, 8, 31)),
    );

    await tasks.updateTaskTitle(taskId, 'Final title');

    final today = await tasks.listTodayTasks();
    expect(today.single.title, 'Final title');
  });

  test('updates task schedule focus timer and repeat fields', () async {
    final taskId = await tasks.createTask(const TaskDraft(title: 'Plan'));

    await tasks.updateTask(
      taskId,
      TaskDraft(
        title: 'Plan updated',
        scheduledDate: DateTime(2026, 9, 1),
        scheduledTime: DateTime(2026, 9, 1, 14, 30),
        focusDurationMinutes: 35,
        recurrenceType: RecurrenceType.weekly,
      ),
    );

    final upcoming = await tasks.listUpcomingTasks();
    expect(upcoming.single.title, 'Plan updated');
    expect(upcoming.single.scheduledDate, DateTime(2026, 9, 1));
    expect(upcoming.single.scheduledTime, DateTime(2026, 9, 1, 14, 30));
    expect(upcoming.single.focusDurationMinutes, 35);
    expect(upcoming.single.seriesId, isNotNull);
  });

  test('repeat none deactivates series and keeps current task', () async {
    final taskId = await tasks.createTask(
      TaskDraft(
        title: 'Weekly review',
        scheduledDate: DateTime(2026, 8, 31),
        recurrenceType: RecurrenceType.weekly,
      ),
    );

    await tasks.updateTask(
      taskId,
      TaskDraft(title: 'Weekly review', scheduledDate: DateTime(2026, 8, 31)),
    );

    final active = await tasks.listTodayTasks();
    expect(active.single.id, taskId);
    expect(active.single.seriesId, isNull);
    final seriesRows = await db.select(db.taskSeries).get();
    expect(seriesRows.single.isActive, isFalse);
  });

  test('deleting custom folder moves its tasks to Inbox', () async {
    final work = await folders.createFolder('Work');
    await tasks.createTask(TaskDraft(title: 'Folder task', folderId: work.id));

    await folders.deleteFolder(work.id);

    final inbox = await folders.inbox();
    final inboxTasks = await tasks.listFolderTasks(inbox.id);
    expect(inboxTasks.single.title, 'Folder task');
  });

  test(
    'completing recurring task generates next occurrence and undo rolls it back',
    () async {
      final taskId = await tasks.createTask(
        TaskDraft(
          title: 'Weekly review',
          scheduledDate: DateTime(2026, 8, 31),
          recurrenceType: RecurrenceType.weekly,
        ),
      );

      final snapshot = await tasks.completeTask(taskId);
      var active = await tasks.listUpcomingTasks();
      expect(active.single.title, 'Weekly review');
      expect(active.single.scheduledDate, DateTime(2026, 9, 7));

      await tasks.restoreTask(snapshot);
      active = await tasks.listTodayTasks();
      expect(active.single.id, taskId);
      active = await tasks.listUpcomingTasks();
      expect(active.single.id, taskId);
    },
  );

  test(
    'custom recurring task uses its interval for the next occurrence',
    () async {
      final taskId = await tasks.createTask(
        TaskDraft(
          title: 'Quarterly-ish review',
          scheduledDate: DateTime(2026, 8, 31),
          recurrenceType: RecurrenceType.weekly,
          recurrenceInterval: 3,
          customRepeatLabel: 'Every 3 weeks',
        ),
      );

      await tasks.completeTask(taskId);

      final active = await tasks.listUpcomingTasks();
      expect(active.single.title, 'Quarterly-ish review');
      expect(active.single.scheduledDate, DateTime(2026, 9, 21));
    },
  );
}


