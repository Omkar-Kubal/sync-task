import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/settings/data/settings_repository.dart';
import 'package:synctask/features/settings/providers/settings_controller.dart';
import 'package:synctask/features/startup/domain/startup_step.dart';
import 'package:synctask/features/startup/screens/startup_flow_screen.dart';

void main() {
  testWidgets('startup first screen opens the second screen', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_app(router));

    expect(find.text('Plan your day'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Protect focus time'), findsOneWidget);
  });

  testWidgets('android back returns to the previous startup screen', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_app(router));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Protect focus time'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(_currentPath(router), '/startup/tasks');
    expect(find.text('Plan your day'), findsOneWidget);
  });

  testWidgets('visible back button matches android back behavior', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_app(router));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(_currentPath(router), '/startup/tasks');
    expect(find.text('Plan your day'), findsOneWidget);
  });

  testWidgets('finishing startup flow persists completion and opens Today', (
    tester,
  ) async {
    final repository = SettingsRepository.memory();
    final router = _router(initialLocation: '/startup/done');
    addTearDown(router.dispose);

    await tester.pumpWidget(_app(router, repository: repository));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(_currentPath(router), '/today');
    expect(find.text('Today destination'), findsOneWidget);
    expect((await repository.load()).hasCompletedStartupFlow, isTrue);
  });
}

GoRouter _router({String initialLocation = '/startup/tasks'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/today',
        builder: (context, state) =>
            const Scaffold(body: Text('Today destination')),
      ),
      GoRoute(
        path: '/startup/tasks',
        builder: (context, state) =>
            const StartupFlowScreen(step: StartupStep.tasks),
      ),
      GoRoute(
        path: '/startup/focus',
        builder: (context, state) =>
            const StartupFlowScreen(step: StartupStep.focus),
      ),
      GoRoute(
        path: '/startup/done',
        builder: (context, state) =>
            const StartupFlowScreen(step: StartupStep.done),
      ),
    ],
  );
}

Widget _app(GoRouter router, {SettingsRepository? repository}) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        repository ?? SettingsRepository.memory(),
      ),
    ],
    child: MaterialApp.router(
      theme: buildSyncTaskTheme(Brightness.light),
      routerConfig: router,
    ),
  );
}

String _currentPath(GoRouter router) {
  return router.routerDelegate.currentConfiguration.uri.path;
}
