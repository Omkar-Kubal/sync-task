import 'package:synctasks/shared/icons/list_filter_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/routing/app_router.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/lists/screens/lists_screen.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/shared/icons/sync_icons.dart';

void main() {
  Future<void> useTallViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('lists screen matches the mockup organization hub', (
    tester,
  ) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: const ProviderScope(child: ListsScreen()),
      ),
    );

    for (final text in [
      'All',
      'Today',
      'Upcoming',
      'Completed',
      'Insights',
      'Organisation hub',
      'MY FOLDERS',
      'Inbox',
      'REMINDERS',
    ]) {
      expect(find.text(text), findsWidgets);
    }

    expect(find.text('Lists'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Lists'));
    expect(title.style?.fontSize, 29);
    expect(find.text('Organization Hub'), findsNothing);
    expect(find.bySemanticsLabel('More list options'), findsNothing);
    expect(find.bySemanticsLabel('Settings'), findsNothing);
    expect(find.bySemanticsLabel('Open All list'), findsOneWidget);
    expect(find.bySemanticsLabel('Open Insights'), findsOneWidget);
    expect(find.bySemanticsLabel('Open Inbox list'), findsOneWidget);
    expect(find.text('Rename Folder'), findsNothing);
  });

  testWidgets('lists screen uses mockup card grouping', (tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: const ProviderScope(child: ListsScreen()),
      ),
    );

    expect(find.byKey(const Key('lists-primary-section')), findsOneWidget);
    expect(find.byKey(const Key('lists-inbox-section')), findsOneWidget);
    expect(find.byKey(const Key('lists-reminders-section')), findsOneWidget);
    expect(find.byKey(const Key('lists-notion-section')), findsNothing);
  });

  testWidgets('lists screen uses shared updated icons', (tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: const ProviderScope(child: ListsScreen()),
      ),
    );

    expect(find.byType(ListFilterIcon), findsWidgets);
    final upcomingCalendar = tester.widget<HugeIcon>(
      find.descendant(
        of: find.bySemanticsLabel('Open Upcoming list'),
        matching: find.byType(HugeIcon),
      ),
    );
    expect(upcomingCalendar.icon, HugeIcons.strokeRoundedCalendar04);
    expect(upcomingCalendar.size, 20);
    expect(upcomingCalendar.strokeWidth, 1.5);
    final completedIcon = tester.widget<HugeIcon>(
      find.descendant(
        of: find.bySemanticsLabel('Open Completed list'),
        matching: find.byType(HugeIcon),
      ),
    );
    expect(completedIcon.icon, HugeIcons.strokeRoundedBookCheck);
    expect(completedIcon.size, 20);
    expect(completedIcon.strokeWidth, 1.5);
    final reminderIcon = tester.widget<HugeIcon>(
      find.descendant(
        of: find.bySemanticsLabel('Open Reminders list'),
        matching: find.byType(HugeIcon),
      ),
    );
    expect(reminderIcon.icon, HugeIcons.strokeRoundedNotification03);
    expect(reminderIcon.size, 20);
    expect(reminderIcon.strokeWidth, 1.5);
    expect(find.byIcon(SyncIcons.upcoming), findsNothing);
    expect(find.byIcon(SyncIcons.completed), findsNothing);
    expect(find.byIcon(SyncIcons.reminder), findsNothing);
    expect(find.byIcon(SyncIcons.folder), findsOneWidget);
    expect(find.byKey(const Key('notion-logo-icon')), findsNothing);
    expect(find.text('N'), findsNothing);
    expect(find.byIcon(Icons.format_list_bulleted_rounded), findsNothing);
    expect(find.byIcon(Icons.calendar_month_rounded), findsNothing);
    expect(find.byIcon(Icons.inbox_rounded), findsNothing);
  });

  testWidgets('lists screen FAB creates an Inbox task', (tester) async {
    await useTallViewport(tester);
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpRoutedApp(tester, db, router);

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Inbox from Lists');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    final tasks = await TaskRepository(db).listAllActiveTasks();
    expect(tasks.single.title, 'Inbox from Lists');

    router.go('/lists/inbox');
    await tester.pumpAndSettle();
    expect(find.text('Inbox from Lists'), findsOneWidget);
  });

  testWidgets('lists screen create sheet can hand off to edit sheet', (
    tester,
  ) async {
    await useTallViewport(tester);
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpRoutedApp(tester, db, router);

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Edit from Lists');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('edit-task-title-field')), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    final tasks = await TaskRepository(db).listAllActiveTasks();
    expect(tasks.single.title, 'Edit from Lists');
    expect(tasks.single.scheduledDate, isNotNull);
  });

  testWidgets('lists screen hides unavailable Notion placeholder row', (
    tester,
  ) async {
    await useTallViewport(tester);
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await _pumpRoutedApp(tester, db, router);

    router.go('/lists');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Open Notion list'), findsNothing);
    expect(find.text('NOTION'), findsNothing);
    expect(find.text('Notion'), findsNothing);
    expect(find.text('Coming soon'), findsNothing);
  });
}

Future<void> _pumpRoutedApp(
  WidgetTester tester,
  AppDatabase db,
  GoRouter router,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        theme: buildSyncTasksTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );
}


