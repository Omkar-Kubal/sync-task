import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/database/app_database.dart';
import 'package:synctask/core/routing/app_router.dart';
import 'package:synctask/core/theme/app_theme.dart';
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
    final router = appRouter();
    addTearDown(router.dispose);
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
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
}

Future<void> _createTodayTask(WidgetTester tester, String title) async {
  await tester.tap(find.bySemanticsLabel('Create task'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.bySemanticsLabel('Submit task'));
  await tester.pumpAndSettle();
}
