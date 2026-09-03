import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/database/app_database.dart';
import 'package:synctask/core/routing/app_router.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/focus/data/active_timer_repository.dart';
import 'package:synctask/features/focus/data/focus_history_repository.dart';
import 'package:synctask/features/focus/providers/focus_controller.dart';
import 'package:synctask/features/tasks/data/task_repository.dart';
import 'package:synctask/features/tasks/domain/task.dart' as domain;
import 'package:synctask/features/tasks/providers/task_controller.dart';
import 'package:synctask/shared/sheets/app_bottom_sheet.dart';

void main() {
  test('app router starts on the splash screen', () {
    final router = appRouter();

    expect(router.routeInformationProvider.value.uri.path, '/splash');
    router.dispose();
  });

  testWidgets('splash screen shows the app logo before opening Today', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    expect(find.byKey(const Key('app-splash-logo')), findsOneWidget);
    expect(find.bySemanticsLabel('Today'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1999));
    expect(router.routeInformationProvider.value.uri.path, '/splash');

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets(
    'secondary pages render inside the shared bottom navigation shell',
    (tester) async {
      final router = appRouter();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: buildSyncTaskTheme(Brightness.light),
            routerConfig: router,
          ),
        ),
      );

      router.go('/lists/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.bySemanticsLabel('Today'), findsOneWidget);
      expect(find.bySemanticsLabel('Upcoming'), findsOneWidget);
      expect(find.bySemanticsLabel('Focus'), findsOneWidget);
      expect(find.bySemanticsLabel('Lists'), findsOneWidget);

      router.dispose();
    },
  );

  testWidgets('task sheets cover the shell bottom navigation area', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final sheetBottom = tester.getBottomLeft(find.byType(AppBottomSheet)).dy;
    final navTop = tester
        .getTopLeft(find.byKey(const Key('sync-bottom-nav-pill')))
        .dy;

    expect(sheetBottom, screenHeight);
    expect(tester.getTopLeft(find.byType(AppBottomSheet)).dy, lessThan(navTop));
  });

  testWidgets('Upcoming refreshes after adding tasks from Today', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final focusController = FocusController(
      activeTimers: ActiveTimerRepository.memory(),
      focusHistory: FocusHistoryRepository(db),
      now: () => DateTime(2026, 9, 2, 10),
    );
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          focusControllerProvider.overrideWithValue(focusController),
        ],
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/upcoming');
    await tester.pumpAndSettle();

    router.go('/today');
    await tester.pumpAndSettle();

    await _createTodayTask(tester, 'First task');
    await _createTodayTask(tester, 'Second task');

    router.go('/upcoming');
    await tester.pumpAndSettle();

    expect(find.text('First task'), findsOneWidget);
    expect(find.text('Second task'), findsOneWidget);
  });

  testWidgets('Today edit sheet keeps Start Focus blocked without a timer', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    final today = DateTime.now();
    await TaskRepository(db).createTask(
      domain.TaskDraft(
        title: 'No timer task',
        scheduledDate: DateTime(today.year, today.month, today.day),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.text('No timer task'));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start Focus'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Start Focus opens Focus with task duration and title', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final focusController = FocusController(
      activeTimers: ActiveTimerRepository.memory(),
      focusHistory: FocusHistoryRepository(db),
      now: () => DateTime(2026, 9, 2, 10),
    );
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    final today = DateTime.now();
    await TaskRepository(db).createTask(
      domain.TaskDraft(
        title: 'Study',
        scheduledDate: DateTime(today.year, today.month, today.day),
        focusDurationMinutes: 45,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          focusControllerProvider.overrideWithValue(focusController),
        ],
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Start Focus'));
    await tester.tap(find.text('Start Focus'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/focus');
    expect(find.text('45:00'), findsOneWidget);
    expect(find.text('Task: Study'), findsOneWidget);
  });

  testWidgets('editing Today task to next week moves it to Upcoming', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    final today = DateTime.now();
    await TaskRepository(db).createTask(
      domain.TaskDraft(
        title: 'Move me',
        scheduledDate: DateTime(today.year, today.month, today.day),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Move me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next Week'));
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Done'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Move me'), findsNothing);

    router.go('/upcoming');
    await tester.pumpAndSettle();

    expect(find.text('Move me'), findsOneWidget);
  });

  testWidgets('enabling Focus Timer in edit sheet starts linked Focus', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final focusController = FocusController(
      activeTimers: ActiveTimerRepository.memory(),
      focusHistory: FocusHistoryRepository(db),
      now: () => DateTime(2026, 9, 2, 10),
    );
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    final today = DateTime.now();
    await TaskRepository(db).createTask(
      domain.TaskDraft(
        title: 'Focus now',
        scheduledDate: DateTime(today.year, today.month, today.day),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          focusControllerProvider.overrideWithValue(focusController),
        ],
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Focus now'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Focus Timer'));
    await tester.tap(find.byKey(const ValueKey('Enable focus timer')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Start Focus'));
    await tester.tap(find.text('Start Focus'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/focus');
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Task: Focus now'), findsOneWidget);
  });

  testWidgets('Focus insights card opens Insights', (tester) async {
    final db = AppDatabase.memory();
    final focusController = FocusController(
      activeTimers: ActiveTimerRepository.memory(),
      focusHistory: FocusHistoryRepository(db),
      now: () => DateTime(2026, 9, 2, 10),
    );
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          focusControllerProvider.overrideWithValue(focusController),
        ],
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/focus');
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Insights'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/focus/insights');
    expect(find.text('Insights'), findsOneWidget);
  });

  testWidgets('Lists placeholder rows open black pages', (tester) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open All list'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists/all');
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(scaffold.backgroundColor, Colors.black);
  });

  testWidgets('Lists real rows keep their real destinations', (tester) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open Today list'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/today');

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/lists/settings');
  });
}

Future<void> _createTodayTask(WidgetTester tester, String title) async {
  await tester.tap(find.bySemanticsLabel('Create task'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.bySemanticsLabel('Submit task'));
  await tester.pumpAndSettle();
}
