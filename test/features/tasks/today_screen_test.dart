import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/routing/app_router.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/settings/screens/settings_screen.dart';
import 'package:synctasks/features/tasks/screens/today_screen.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap({Brightness brightness = Brightness.light}) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(
          RecordingNotificationScheduler(),
        ),
      ],
      child: MaterialApp(
        theme: buildSyncTasksTheme(brightness),
        home: const TodayScreen(),
      ),
    );
  }

  testWidgets('create task button opens the create task sheet', (tester) async {
    await tester.pumpWidget(wrap());

    expect(
      find.widgetWithText(FilledButton, 'Create new task'),
      findsOneWidget,
    );

    await tester.tap(find.text('Create new task'));
    await tester.pumpAndSettle();

    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Today'), findsOneWidget);
  });

  testWidgets('empty home state matches the mockup content and actions', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('${DateTime.now().day}'), findsOneWidget);
    expect(find.text('Sept'), findsOneWidget);
    expect(find.text("You're clear for today."), findsOneWidget);
    expect(
      find.text('Create a task whenever something pops up.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Open Upcoming'), findsOneWidget);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    expect(find.text('Upcoming'), findsNothing);
    expect(find.bySemanticsLabel('More options'), findsNothing);
    expect(find.bySemanticsLabel('Search tasks'), findsOneWidget);
  });

  testWidgets('home chrome stays compact at the top of Android screens', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    final titleText = tester.widget<Text>(find.text('Today'));
    final dateText = tester.widget<Text>(find.text('${DateTime.now().day}'));
    final topActionsSize = tester.getSize(
      find.byKey(const Key('today-top-actions-pill')),
    );
    final upcomingSize = tester.getSize(find.bySemanticsLabel('Open Upcoming'));
    final searchSize = tester.getSize(find.bySemanticsLabel('Search tasks'));
    final settingsSize = tester.getSize(find.bySemanticsLabel('Settings'));

    expect(titleText.style?.fontSize, 29);
    expect(dateText.style?.fontSize, 19);
    expect(topActionsSize.height, 52);
    expect(upcomingSize, const Size(46, 46));
    expect(searchSize, const Size(46, 46));
    expect(settingsSize, const Size(46, 46));
    expect(find.byType(VerticalDivider), findsNothing);

    final topActions = tester.widget<Container>(
      find.byKey(const Key('today-top-actions-pill')),
    );
    final decoration = topActions.decoration! as BoxDecoration;
    expect(decoration.border, isNull);
    expect(decoration.boxShadow, isNotNull);
    expect(decoration.boxShadow!.single.blurRadius, greaterThanOrEqualTo(16));

    for (final label in ['Open Upcoming', 'Search tasks', 'Settings']) {
      final button = tester.widget<IconButton>(
        find.descendant(
          of: find.bySemanticsLabel(label),
          matching: find.byType(IconButton),
        ),
      );
      expect(button.style?.backgroundColor?.resolve({}), Colors.transparent);
      expect(button.style?.side?.resolve({}), BorderSide.none);
    }
  });

  testWidgets('settings top action uses Hugeicons Setting 07', (tester) async {
    await tester.pumpWidget(wrap());

    final icon = tester.widget<HugeIcon>(
      find.descendant(
        of: find.bySemanticsLabel('Settings'),
        matching: find.byType(HugeIcon),
      ),
    );

    expect(icon.icon, HugeIcons.strokeRoundedSetting07);
    expect(icon.size, 28);
    expect(icon.strokeWidth, 1.5);
  });

  testWidgets('settings top action opens Settings as a full-screen sheet', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    final settingsScaffold = find.descendant(
      of: find.byType(SettingsScreen),
      matching: find.byType(Scaffold),
    );
    expect(tester.getTopLeft(settingsScaffold).dy, 0);
    expect(
      tester.getSize(settingsScaffold),
      tester.view.physicalSize / tester.view.devicePixelRatio,
    );

    await tester.tap(find.bySemanticsLabel('Close settings'));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('upcoming top action uses Hugeicons Calendar 04', (tester) async {
    await tester.pumpWidget(wrap());

    final icon = tester.widget<HugeIcon>(
      find.descendant(
        of: find.bySemanticsLabel('Open Upcoming'),
        matching: find.byType(HugeIcon),
      ),
    );

    expect(icon.icon, HugeIcons.strokeRoundedCalendar04);
    expect(icon.size, 28);
    expect(icon.strokeWidth, 1.5);
  });

  testWidgets('search top action opens live task search', (tester) async {
    final router = appRouter();
    addTearDown(router.dispose);
    await TaskRepository(db).createTask(
      domain.TaskDraft(title: 'Find this task', scheduledDate: DateTime.now()),
    );

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

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Search tasks'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today/search');

    await tester.enterText(find.byType(TextField), 'Find');
    await tester.pumpAndSettle();

    expect(find.text('Find this task'), findsOneWidget);
  });

  testWidgets('home chrome puts the date below Today and omits more options', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    final titleBottom = tester.getBottomLeft(find.text('Today')).dy;
    final dateTop = tester.getTopLeft(find.text('${DateTime.now().day}')).dy;
    final monthTop = tester.getTopLeft(find.text('Sept')).dy;

    expect(dateTop, greaterThan(titleBottom));
    expect(monthTop, greaterThan(dateTop));
    expect(find.bySemanticsLabel('More options'), findsNothing);
    expect(find.text('View'), findsNothing);
    expect(find.text('Select tasks'), findsNothing);
  });

  testWidgets('create task button uses compact Android sizing', (tester) async {
    await tester.pumpWidget(wrap());

    final button = find.widgetWithText(FilledButton, 'Create new task');
    final buttonText = tester.widget<Text>(find.text('Create new task'));

    expect(tester.getSize(button), const Size(160, 40));
    expect(buttonText.style?.fontSize, 14);
  });

  testWidgets('create task button label remains visible in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(brightness: Brightness.dark));

    final buttonText = tester.widget<Text>(find.text('Create new task'));

    expect(buttonText.style?.color, const Color(0xFF000000));
  });

  testWidgets('floating create button opens the create task sheet', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();

    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Today'), findsOneWidget);
  });

  testWidgets('submitting a task creates it in the Today list', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Plan sprint');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    expect(find.text('Plan sprint'), findsOneWidget);
    expect(find.text("You're clear for today."), findsNothing);
  });

  testWidgets('yesterday incomplete task stays on Today in red', (
    tester,
  ) async {
    final repository = TaskRepository(db);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await repository.createTask(
      domain.TaskDraft(
        title: 'Missed follow up',
        scheduledDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final titleText = tester.widget<Text>(find.text('Missed follow up'));

    expect(titleText.style?.color, const Color(0xFFD92D20));
    expect(find.widgetWithText(TextButton, 'Reschedule'), findsOneWidget);
  });

  testWidgets('reschedule action moves overdue task to today', (tester) async {
    final repository = TaskRepository(db);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final taskId = await repository.createTask(
      domain.TaskDraft(
        title: 'Move missed task',
        scheduledDate: DateTime(yesterday.year, yesterday.month, yesterday.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Reschedule'));
    await tester.pumpAndSettle();

    final today = DateTime.now();
    final expectedDate = DateTime(today.year, today.month, today.day);
    final task = await repository.getTask(taskId);
    final titleText = tester.widget<Text>(find.text('Move missed task'));

    expect(task?.scheduledDate, expectedDate);
    expect(titleText.style?.color, const Color(0xFF000000));
    expect(find.widgetWithText(TextButton, 'Reschedule'), findsNothing);
  });

  testWidgets('today incomplete task stays normal instead of red', (
    tester,
  ) async {
    final repository = TaskRepository(db);
    await repository.createTask(
      domain.TaskDraft(title: 'Due today', scheduledDate: DateTime.now()),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final titleText = tester.widget<Text>(find.text('Due today'));

    expect(titleText.style?.color, const Color(0xFF000000));
    expect(find.widgetWithText(TextButton, 'Reschedule'), findsNothing);
  });

  testWidgets('editing a task title updates the Today list', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Plan sprint');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plan sprint'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.text('Task title'), findsNothing);
    expect(find.byKey(const Key('edit-task-title-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('edit-task-title-field')),
      'Plan launch',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Plan launch'), findsOneWidget);
    expect(find.text('Plan sprint'), findsNothing);
  });

  testWidgets('tapping the task completion circle removes it from Today', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Plan sprint');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('task-row-checkbox-button')));
    await tester.pumpAndSettle();

    expect(find.text('Plan sprint'), findsNothing);
    expect(find.text("You're clear for today."), findsOneWidget);
  });

  testWidgets('bulk complete marks selected Today tasks done', (tester) async {
    final repository = TaskRepository(db);
    await repository.createTask(
      domain.TaskDraft(title: 'Batch one', scheduledDate: DateTime.now()),
    );
    await repository.createTask(
      domain.TaskDraft(title: 'Batch two', scheduledDate: DateTime.now()),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Batch one'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batch two'));
    await tester.pumpAndSettle();

    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Complete selected tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Batch one'), findsNothing);
    expect(find.text('Batch two'), findsNothing);

    final tasks = await db.select(db.tasks).get();
    expect(tasks.every((task) => task.isCompleted), isTrue);
  });

  testWidgets('bulk delete removes selected Today tasks', (tester) async {
    final repository = TaskRepository(db);
    await repository.createTask(
      domain.TaskDraft(title: 'Delete one', scheduledDate: DateTime.now()),
    );
    await repository.createTask(
      domain.TaskDraft(title: 'Delete two', scheduledDate: DateTime.now()),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Delete one'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete two'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Delete selected tasks'));
    await tester.pumpAndSettle();

    expect(find.text('Delete one'), findsNothing);
    expect(find.text('Delete two'), findsNothing);
    expect(await db.select(db.tasks).get(), isEmpty);
  });

  testWidgets('bulk reschedule moves selected Today tasks to tomorrow', (
    tester,
  ) async {
    final repository = TaskRepository(db);
    final firstId = await repository.createTask(
      domain.TaskDraft(title: 'Tomorrow one', scheduledDate: DateTime.now()),
    );
    final secondId = await repository.createTask(
      domain.TaskDraft(title: 'Tomorrow two', scheduledDate: DateTime.now()),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Tomorrow one'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tomorrow two'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Reschedule selected tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();

    expect(find.text('Tomorrow one'), findsNothing);
    expect(find.text('Tomorrow two'), findsNothing);

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final expectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final first = await repository.getTask(firstId);
    final second = await repository.getTask(secondId);
    expect(first?.scheduledDate, expectedDate);
    expect(second?.scheduledDate, expectedDate);
  });

  testWidgets('bulk move sends selected Today tasks to another folder', (
    tester,
  ) async {
    final repository = TaskRepository(db);
    final folderRepository = FolderRepository(db);
    final workFolder = await folderRepository.createFolder('Work');
    final firstId = await repository.createTask(
      domain.TaskDraft(title: 'Move one', scheduledDate: DateTime.now()),
    );
    final secondId = await repository.createTask(
      domain.TaskDraft(title: 'Move two', scheduledDate: DateTime.now()),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Move one'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move two'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Move selected tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    final first = await repository.getTask(firstId);
    final second = await repository.getTask(secondId);
    expect(first?.folderId, workFolder.id);
    expect(second?.folderId, workFolder.id);
  });

  testWidgets('selecting Today opens the edit task sheet', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('None'), findsWidgets);
  });

  testWidgets('task sheets use the design-system modal veil', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();

    final barrierColors = tester
        .widgetList<ModalBarrier>(find.byType(ModalBarrier))
        .map((barrier) => barrier.color);
    expect(barrierColors, contains(const Color(0xB8000000)));
  });
}
