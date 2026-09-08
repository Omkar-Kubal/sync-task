import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/onboarding/screens/onboarding_screen.dart';
import 'package:synctasks/features/settings/data/settings_repository.dart';
import 'package:synctasks/features/settings/providers/settings_controller.dart';

void main() {
  testWidgets('onboarding starts on the welcome page', (tester) async {
    await tester.pumpWidget(_onboardingApp(SettingsRepository.memory()));

    expect(find.text('Plan today with less noise'), findsOneWidget);
    expect(find.text('Start with Today'), findsNothing);
    expect(find.bySemanticsLabel('Today'), findsNothing);
    expect(find.byKey(const Key('onboarding-welcome-logo')), findsOneWidget);
  });

  testWidgets('arrow button advances pages without a back action', (
    tester,
  ) async {
    await tester.pumpWidget(_onboardingApp(SettingsRepository.memory()));

    expect(find.text('Next'), findsNothing);
    expect(find.text('Back'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Next onboarding page'));
    await tester.pumpAndSettle();

    expect(find.text('Start with Today'), findsOneWidget);
    expect(find.byKey(const Key('onboarding-today-app-image')), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('android back returns to the previous onboarding page', (
    tester,
  ) async {
    await tester.pumpWidget(_onboardingApp(SettingsRepository.memory()));

    await tester.tap(find.bySemanticsLabel('Next onboarding page'));
    await tester.pumpAndSettle();
    expect(find.text('Start with Today'), findsOneWidget);

    final didHandleBack = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(didHandleBack, isTrue);
    expect(find.text('Plan today with less noise'), findsOneWidget);
    expect(find.text('Start with Today'), findsNothing);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('onboarding does not show a skip action', (tester) async {
    final repository = SettingsRepository.memory();

    await tester.pumpWidget(_onboardingApp(repository));

    expect(find.text('Skip'), findsNothing);
    expect((await repository.load()).hasCompletedOnboarding, isFalse);
  });

  testWidgets('get started completes onboarding and opens Today', (
    tester,
  ) async {
    final repository = SettingsRepository.memory();
    final router = _testRouter(repository);
    addTearDown(router.dispose);

    await tester.pumpWidget(_routedOnboardingApp(repository, router));

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.bySemanticsLabel('Next onboarding page'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    expect((await repository.load()).hasCompletedOnboarding, isTrue);
  });
}

Widget _onboardingApp(SettingsRepository repository) {
  return ProviderScope(
    overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: buildSyncTasksTheme(Brightness.light),
      home: const OnboardingScreen(),
    ),
  );
}

Widget _routedOnboardingApp(SettingsRepository repository, GoRouter router) {
  return ProviderScope(
    overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      theme: buildSyncTasksTheme(Brightness.light),
      routerConfig: router,
    ),
  );
}

GoRouter _testRouter(SettingsRepository repository) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/today',
        builder: (context, state) => const Scaffold(body: Text('Today')),
      ),
    ],
  );
}


