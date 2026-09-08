import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/routing/app_router.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;
import 'package:synctasks/features/tasks/providers/task_controller.dart';

void main() {
  testWidgets('list detail header uses a compact title and close button', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/all');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Close list'), findsOneWidget);
    expect(find.bySemanticsLabel('Back to Lists'), findsNothing);
    final title = tester.widget<Text>(find.text('All'));
    expect(title.style?.fontSize, 25);
  });

  testWidgets('folder route displays folder name and creates tasks there', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final folder = await FolderRepository(db).createFolder('Work');
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/folder/${folder.id}');
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Create new task'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsWidgets);
    await tester.enterText(find.byType(TextField), 'Folder task');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    final folderTasks = await TaskRepository(db).listFolderTasks(folder.id);
    expect(folderTasks.single.title, 'Folder task');
    expect(find.text('Folder task'), findsOneWidget);
  });

  testWidgets('folder detail create sheet respects selected folder', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final work = await FolderRepository(db).createFolder('Work');
    final personal = await FolderRepository(db).createFolder('Personal');
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/folder/${work.id}');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create new task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Work'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Chosen folder task');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    expect(await TaskRepository(db).listFolderTasks(work.id), isEmpty);
    final personalTasks = await TaskRepository(db).listFolderTasks(personal.id);
    expect(personalTasks.single.title, 'Chosen folder task');
  });

  testWidgets('missing folder route shows empty state instead of crashing', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/folder/404');
    await tester.pumpAndSettle();

    expect(find.text('Folder'), findsOneWidget);
    expect(find.text('This folder no longer exists.'), findsOneWidget);
    expect(find.bySemanticsLabel('Create task'), findsNothing);
  });

  testWidgets('completed screen groups tasks by completion date', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day, 9);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    final earlierDate = todayDate.subtract(const Duration(days: 3));

    final todayTask = await TaskRepository(
      db,
    ).createTask(const domain.TaskDraft(title: 'Done today'));
    await TaskRepository(db, now: () => todayDate).completeTask(todayTask);

    final yesterdayTask = await TaskRepository(
      db,
    ).createTask(const domain.TaskDraft(title: 'Done yesterday'));
    await TaskRepository(
      db,
      now: () => yesterdayDate,
    ).completeTask(yesterdayTask);

    final earlierTask = await TaskRepository(
      db,
    ).createTask(const domain.TaskDraft(title: 'Done earlier'));
    await TaskRepository(db, now: () => earlierDate).completeTask(earlierTask);

    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/completed');
    await tester.pumpAndSettle();

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);
    expect(find.text('EARLIER'), findsOneWidget);
    expect(find.text('Done today'), findsOneWidget);
    expect(find.text('Done yesterday'), findsOneWidget);
    expect(find.text('Done earlier'), findsOneWidget);
    expect(find.bySemanticsLabel('Restore task'), findsNWidgets(3));
    expect(find.bySemanticsLabel('Complete task'), findsNothing);
  });

  testWidgets('all screen refreshes after editing and completing a task', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    await TaskRepository(db).createTask(const domain.TaskDraft(title: 'Draft'));
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/all');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Draft'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('edit-task-title-field')),
      'Edited',
    );
    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    expect(find.text('Edited'), findsOneWidget);
    expect(find.text('Draft'), findsNothing);

    await tester.tap(find.byKey(const Key('task-row-checkbox-button')));
    await tester.pumpAndSettle();

    expect(find.text('Edited'), findsNothing);

    router.go('/lists/completed');
    await tester.pumpAndSettle();

    expect(find.text('Edited'), findsOneWidget);
  });

  testWidgets('reminders create keeps the new task visible in reminders', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/reminders');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create new task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Reminder task');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    expect(find.text('Reminder task'), findsOneWidget);

    final reminders = await TaskRepository(db).listReminderTasks();
    expect(reminders.single.title, 'Reminder task');
    expect(reminders.single.reminderTime, isNotNull);
  });

  testWidgets('all screen refreshes after a task is created from Today', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/all');
    await tester.pumpAndSettle();
    expect(find.text('No tasks found'), findsOneWidget);

    router.go('/today');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Created from Today');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    router.go('/lists/all');
    await tester.pumpAndSettle();

    expect(find.text('Created from Today'), findsOneWidget);
  });

  testWidgets('empty list detail create button opens task create sheet', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/all');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create new task'));
    await tester.pumpAndSettle();

    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Inbox'), findsWidgets);
  });

  testWidgets('empty list detail shows only one create affordance', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpApp(tester, db, router);

    router.go('/lists/all');
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(FilledButton, 'Create new task'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Create task'), findsNothing);
  });
}

Future<void> _pumpApp(
  WidgetTester tester,
  AppDatabase db,
  GoRouter router,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(
          RecordingNotificationScheduler(),
        ),
      ],
      child: MaterialApp.router(
        theme: buildSyncTasksTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );
}


