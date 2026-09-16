import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/routing/app_router.dart';
import 'package:synctasks/core/routing/safe_back_button_dispatcher.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/settings/data/settings_repository.dart';
import 'package:synctasks/features/settings/domain/app_settings.dart';
import 'package:synctasks/features/settings/providers/settings_controller.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/shared/sheets/app_bottom_sheet.dart';

void main() {
  test(
    'safe back dispatcher ignores empty go_router match stack errors',
    () async {
      final dispatcher = SafeBackButtonDispatcher();
      Future<bool> cb() => Future<bool>.error(StateError('No element'));
      dispatcher.addCallback(cb);
      expect(await dispatcher.didPopRoute(), isFalse);
      dispatcher.removeCallback(cb);
    },
  );

  test('safe back dispatcher rethrows unrelated state errors', () async {
    final dispatcher = SafeBackButtonDispatcher();
    Future<bool> cb() => Future<bool>.error(StateError('different failure'));
    dispatcher.addCallback(cb);
    await expectLater(dispatcher.didPopRoute(), throwsStateError);
    dispatcher.removeCallback(cb);
  });

  test('app router starts on the splash screen', () {
    final router = appRouter();

    expect(router.routeInformationProvider.value.uri.path, '/splash');
    router.dispose();
  });

  testWidgets('splash screen shows the app logo before opening onboarding', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    expect(find.byKey(const Key('app-splash-logo')), findsOneWidget);
    expect(find.bySemanticsLabel('Today'), findsNothing);

    await tester.pump(const Duration(milliseconds: 699));
    expect(router.routeInformationProvider.value.uri.path, '/splash');

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/onboarding');
    expect(find.text('Plan today with less noise'), findsOneWidget);
  });

  testWidgets('widget Today deep link opens Today instead of page not found', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('synctasks://today');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.text('Page Not Found'), findsNothing);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('widget Today deep link handles Android back without exception', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('synctasks://today');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('quick-add route handles Android back without router exception', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('/quick-add');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/quick-add');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('splash opens Today when onboarding is complete', (tester) async {
    final repository = SettingsRepository.memory();
    await repository.save(const AppSettings(hasCompletedOnboarding: true));
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(
      tester,
      router,
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('settings renders outside the shared bottom navigation shell', (
    tester,
  ) async {
    final router = appRouter();

    await pumpRouterApp(tester, router);

    router.go('/lists/settings');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/settings');
    expect(find.text('Settings'), findsOneWidget);
    expect(find.bySemanticsLabel('Today'), findsNothing);
    expect(find.bySemanticsLabel('Focus'), findsNothing);
    expect(find.bySemanticsLabel('Lists'), findsNothing);

    router.dispose();
  });

  testWidgets('Today top bar opens Upcoming as a full-page bottom sheet', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open Upcoming'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.bySemanticsLabel('Close Upcoming'), findsOneWidget);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.getTopLeft(find.text('Upcoming')).dy, lessThan(48));

    await tester.tap(find.bySemanticsLabel('Close Upcoming'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsNothing);
  });

  testWidgets('Today top bar opens Upcoming without a route slide transition', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open Upcoming'));
    await tester.pump();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.text('Upcoming'), findsOneWidget);
    expect(_routeHasActiveSlide(tester), isFalse);
  });

  testWidgets('task sheets cover the shell bottom navigation area', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

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
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
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

  testWidgets(
    'Focus is not exposed as a routed bottom navigation destination',
    (tester) async {
      final router = appRouter();
      addTearDown(router.dispose);

      await pumpRouterApp(tester, router);

      router.go('/today');
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Focus'), findsNothing);

      router.go('/focus');
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, isNot('/focus'));
      expect(find.text('Focus'), findsNothing);
      expect(find.text('Start Focus'), findsNothing);
    },
  );

  testWidgets('Today edit sheet can save a new task', (tester) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('edit-task-title-field')),
      'Saved from edit',
    );
    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    expect(find.text('Saved from edit'), findsOneWidget);
  });

  testWidgets('Today edit sheet does not expose Focus actions', (tester) async {
    final db = AppDatabase.memory();
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
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();

    expect(find.text('Focus Timer'), findsNothing);
    expect(find.text('Start Focus'), findsNothing);
    expect(router.routeInformationProvider.value.uri.path, '/today');
  });

  testWidgets('Today quick Tomorrow action creates task for Upcoming', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Plan tomorrow');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));
    await tester.pumpAndSettle();

    expect(find.text('Plan tomorrow'), findsOneWidget);

    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.text('Plan tomorrow'), findsNothing);

    router.go('/upcoming');
    await tester.pumpAndSettle();

    expect(find.text('Plan tomorrow'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
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
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Move me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next Week'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Move me'), findsNothing);

    router.go('/upcoming');
    await tester.pumpAndSettle();

    expect(find.text('Move me'), findsOneWidget);
  });

  testWidgets('Lists detail rows open real task list bottom sheets', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open All list'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.descendant(of: find.byType(BottomSheet), matching: find.text('All')),
      findsOneWidget,
    );
    expect(find.text('No tasks found'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close list'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.bySemanticsLabel('Open Completed list'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Completed'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.bySemanticsLabel('Create task'),
      ),
      findsNothing,
    );

    await tester.tap(find.bySemanticsLabel('Close list'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open Inbox list'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Inbox'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Close list'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.bySemanticsLabel('Open Reminders list'),
      180,
    );
    final remindersRow = tester.getRect(
      find.bySemanticsLabel('Open Reminders list'),
    );
    await tester.tapAt(Offset(remindersRow.center.dx, remindersRow.top + 12));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Reminders'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'Lists Insights row opens routed Insights without changing bottom nav',
    (tester) async {
      final db = AppDatabase.memory();
      final router = appRouter();
      addTearDown(router.dispose);
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            notificationServiceProvider.overrideWithValue(
              RecordingNotificationScheduler(),
            ),
          ],
          child: buildRouterApp(router),
        ),
      );

      router.go('/lists');
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Open Insights'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/lists/insights');
      expect(find.text('Insights'), findsOneWidget);
      expect(find.bySemanticsLabel('Today'), findsAtLeastNWidgets(1));
      expect(find.bySemanticsLabel('Lists'), findsAtLeastNWidgets(1));
      expect(find.bySemanticsLabel('Focus'), findsNothing);
    },
  );

  testWidgets('Lists detail bottom sheets start half height and drag upward', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open All list'));
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    expect(sheet, findsOneWidget);

    final initialTop = tester.getTopLeft(sheet).dy;
    expect(initialTop, greaterThan(220));
    expect(initialTop, lessThan(360));

    await tester.drag(sheet, const Offset(0, -260));
    await tester.pumpAndSettle();

    final expandedTop = tester.getTopLeft(sheet).dy;
    expect(expandedTop, lessThan(initialTop - 80));
  });

  testWidgets('Lists hides unavailable Notion placeholder row', (tester) async {
    final notionRouter = appRouter();
    addTearDown(notionRouter.dispose);

    await pumpRouterConfigApp(tester, notionRouter);

    notionRouter.go('/lists');
    await tester.pumpAndSettle();

    expect(notionRouter.routeInformationProvider.value.uri.path, '/lists');
    expect(find.bySemanticsLabel('Open Notion list'), findsNothing);
    expect(find.text('Notion'), findsNothing);
  });

  testWidgets('direct Lists routes navigate Close list', (tester) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/lists/all');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Close list'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
    expect(find.text('Lists'), findsOneWidget);

    router.go('/lists/more');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Close list'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
  });

  testWidgets('Android back closes Lists bottom sheets before leaving Lists', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open All list'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Lists'), findsOneWidget);
  });

  testWidgets('Android back on direct Lists sub routes returns to Lists', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: buildRouterApp(router),
      ),
    );

    router.go('/lists/all');
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
    expect(find.text('Lists'), findsOneWidget);

    router.go('/lists/more');
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
  });

  testWidgets('Lists app rows keep expected destinations and sheets', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Lists'), findsNothing);

    router.go('/lists');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Settings'), findsNothing);
    expect(find.bySemanticsLabel('More list options'), findsNothing);
  });

  testWidgets('Lists Today shortcut preserves back navigation to Lists', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('/lists');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('lists-today-shortcut-row')));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Lists'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Lists'), findsOneWidget);
  });

  testWidgets('bottom nav route transitions follow navigation direction', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Lists'));
    await tester.pump();
    final forwardDx = _routeSlideDx(tester);
    expect(forwardDx, greaterThan(0));
    expect(forwardDx, lessThan(0.16));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Today'));
    await tester.pump();
    final backwardDx = _routeSlideDx(tester);
    expect(backwardDx, lessThan(0));
    expect(backwardDx.abs(), lessThan(0.16));
  });

  testWidgets('settings redirects to Today screen and not Lists screen', (
    tester,
  ) async {
    final router = appRouter();
    addTearDown(router.dispose);

    await pumpRouterApp(tester, router);

    router.go('/lists/settings');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/settings');
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.text('Today'), findsOneWidget);

    router.go('/lists/settings');
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect(find.text('Today'), findsOneWidget);
  });
}

Future<void> _createTodayTask(WidgetTester tester, String title) async {
  await tester.tap(find.bySemanticsLabel('Create task'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.bySemanticsLabel('Submit task'));
  await tester.pumpAndSettle();
}

double _routeSlideDx(WidgetTester tester) {
  final transitions = tester
      .widgetList<SlideTransition>(find.byKey(const Key('nav-page-slide')))
      .toList();
  expect(transitions, isNotEmpty);
  final activeTransition = transitions.where(
    (transition) => transition.position.value.dx != 0,
  );
  expect(activeTransition, isNotEmpty);
  return activeTransition.first.position.value.dx;
}

bool _routeHasActiveSlide(WidgetTester tester) {
  final transitions = tester
      .widgetList<SlideTransition>(find.byKey(const Key('nav-page-slide')))
      .toList();
  return transitions.any((transition) => transition.position.value.dx != 0);
}

Future<void> pumpRouterApp(
  WidgetTester tester,
  GoRouter router, {
  List overrides = const [],
}) async {
  final db = AppDatabase.memory();
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(
          RecordingNotificationScheduler(),
        ),
        ...overrides,
      ],
      child: buildRouterApp(router),
    ),
  );
}

Future<void> pumpRouterConfigApp(
  WidgetTester tester,
  GoRouter router, {
  List overrides = const [],
}) async {
  final db = AppDatabase.memory();
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(
          RecordingNotificationScheduler(),
        ),
        ...overrides,
      ],
      child: MaterialApp.router(
        theme: buildSyncTasksTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );
}

Widget buildRouterApp(GoRouter router) {
  return MaterialApp.router(
    theme: buildSyncTasksTheme(Brightness.light),
    routerDelegate: router.routerDelegate,
    routeInformationParser: router.routeInformationParser,
    routeInformationProvider: router.routeInformationProvider,
    backButtonDispatcher: SafeBackButtonDispatcher(),
  );
}
