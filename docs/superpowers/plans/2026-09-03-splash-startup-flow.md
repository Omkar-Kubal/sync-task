# Splash Startup Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a smooth first-run startup flow that begins immediately after the splash screen and supports Android back-button navigation between flow screens.

**Architecture:** Keep `/splash` as the transient app entry route, then route to a new `/startup` flow before the bottom-navigation shell. The flow uses `go_router` child routes with shared custom transitions, while completion state is persisted through the existing settings/shared-preferences layer so returning users go straight to `/today`.

**Tech Stack:** Flutter, Dart, `go_router` 14.6.0, Riverpod 3, `shared_preferences`, Flutter widget tests.

**Spec:** User request from 2026-09-03: "add a flow to synctask right from the splash screen. Each transition between screens should be smooth and user should be able to go back with the android back button."

## Global Constraints

- The app must continue to launch at `/splash`.
- Splash must remain transient and must not reappear when pressing Android back from the first flow screen.
- The startup flow must appear before `/today` for users who have not completed it.
- Every startup-flow screen transition must be animated.
- Android back must pop to the previous startup-flow screen.
- Bottom navigation must remain exactly `Today | Upcoming | Focus | Lists`.
- Existing task, focus, lists, settings, and shell routes must keep their current paths.
- Use existing SyncTask theme tokens, shared widgets, and image assets.
- Do not add a new navigation package.

---

## File Structure

Modify existing files:

```text
lib/app.dart
lib/core/routing/app_router.dart
lib/features/settings/data/settings_repository.dart
lib/features/settings/domain/app_settings.dart
lib/features/settings/providers/settings_controller.dart
lib/features/splash/screens/splash_screen.dart
test/core/routing/app_router_test.dart
test/features/settings/settings_controller_test.dart
test/app_smoke_test.dart
```

Create new startup-flow files:

```text
lib/features/startup/domain/startup_step.dart
lib/features/startup/screens/startup_flow_screen.dart
lib/features/startup/widgets/startup_step_page.dart
test/features/startup/startup_flow_screen_test.dart
```

---

### Task 1: Persist Startup Flow Completion

**Files:**
- Modify: `lib/features/settings/domain/app_settings.dart`
- Modify: `lib/features/settings/data/settings_repository.dart`
- Modify: `lib/features/settings/providers/settings_controller.dart`
- Test: `test/features/settings/settings_controller_test.dart`

**Interfaces:**
- Produces: `AppSettings.hasCompletedStartupFlow`
- Produces: `SettingsController.setStartupFlowCompleted(bool completed)`
- Produces: shared-preferences key `settings.hasCompletedStartupFlow`

- [ ] **Step 1: Inspect current settings model**

Run:

```powershell
Get-Content -Path lib\features\settings\domain\app_settings.dart
Get-Content -Path lib\features\settings\data\settings_repository.dart
Get-Content -Path lib\features\settings\providers\settings_controller.dart
```

Expected: `AppSettings` already supports `copyWith`, and `SettingsRepository.memory()` is used by tests.

- [ ] **Step 2: Write the failing settings test**

Add this test to `test/features/settings/settings_controller_test.dart`:

```dart
test('settings controller persists startup flow completion', () async {
  final repository = SettingsRepository.memory();
  final controller = SettingsController(repository);

  expect((await repository.load()).hasCompletedStartupFlow, isFalse);

  await controller.setStartupFlowCompleted(true);

  expect((await repository.load()).hasCompletedStartupFlow, isTrue);
});
```

- [ ] **Step 3: Run test to verify it fails**

Run:

```powershell
flutter test test/features/settings/settings_controller_test.dart
```

Expected: FAIL because `hasCompletedStartupFlow` and `setStartupFlowCompleted` do not exist.

- [ ] **Step 4: Add the setting**

Update `AppSettings` with:

```dart
final bool hasCompletedStartupFlow;
```

Default it to `false`, and include it in `copyWith`:

```dart
bool? hasCompletedStartupFlow,
```

```dart
hasCompletedStartupFlow:
    hasCompletedStartupFlow ?? this.hasCompletedStartupFlow,
```

Update `SettingsRepository` with:

```dart
static const _hasCompletedStartupFlowKey =
    'settings.hasCompletedStartupFlow';
```

Load it with:

```dart
hasCompletedStartupFlow:
    preferences.getBool(_hasCompletedStartupFlowKey) ?? false,
```

Save it with:

```dart
await preferences.setBool(
  _hasCompletedStartupFlowKey,
  settings.hasCompletedStartupFlow,
);
```

Update `SettingsController` with:

```dart
Future<void> setStartupFlowCompleted(bool completed) async {
  final settings = await _repository.load();
  await _repository.save(
    settings.copyWith(hasCompletedStartupFlow: completed),
  );
}
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```powershell
flutter test test/features/settings/settings_controller_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```powershell
git add lib/features/settings test/features/settings
git commit -m "feat: persist startup flow completion"
```

---

### Task 2: Add Startup Flow Screens

**Files:**
- Create: `lib/features/startup/domain/startup_step.dart`
- Create: `lib/features/startup/widgets/startup_step_page.dart`
- Create: `lib/features/startup/screens/startup_flow_screen.dart`
- Test: `test/features/startup/startup_flow_screen_test.dart`

**Interfaces:**
- Produces: `StartupStep`
- Produces: `StartupFlowScreen(step: StartupStep)`
- Consumes: `SettingsController.setStartupFlowCompleted(true)`
- Consumes: `GoRouter.push`, `GoRouter.pop`, and `GoRouter.go`

- [ ] **Step 1: Write the failing widget tests**

Create `test/features/startup/startup_flow_screen_test.dart` with tests for all user-visible screens:

```dart
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

    expect(router.routeInformationProvider.value.uri.path, '/startup/focus');
    expect(find.text('Protect focus time'), findsOneWidget);
  });

  testWidgets('android back returns to the previous startup screen', (
    tester,
  ) async {
    final router = _router(initialLocation: '/startup/focus');
    addTearDown(router.dispose);

    await tester.pumpWidget(_app(router));
    expect(find.text('Protect focus time'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/startup/tasks');
    expect(find.text('Plan your day'), findsOneWidget);
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

Widget _app(GoRouter router) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(SettingsRepository.memory()),
    ],
    child: MaterialApp.router(
      theme: buildSyncTaskTheme(Brightness.light),
      routerConfig: router,
    ),
  );
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/features/startup/startup_flow_screen_test.dart
```

Expected: FAIL because startup files do not exist.

- [ ] **Step 3: Create startup step domain**

Implement `lib/features/startup/domain/startup_step.dart`:

```dart
enum StartupStep {
  tasks,
  focus,
  done;

  String get routePath {
    return switch (this) {
      StartupStep.tasks => '/startup/tasks',
      StartupStep.focus => '/startup/focus',
      StartupStep.done => '/startup/done',
    };
  }

  StartupStep? get next {
    return switch (this) {
      StartupStep.tasks => StartupStep.focus,
      StartupStep.focus => StartupStep.done,
      StartupStep.done => null,
    };
  }
}
```

- [ ] **Step 4: Create the reusable page widget**

Implement `StartupStepPage` as a focused UI component:

```dart
class StartupStepPage extends StatelessWidget {
  const StartupStepPage({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.canGoBack = false,
    this.onBackPressed,
    super.key,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final bool canGoBack;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: canGoBack
                    ? IconButton(
                        onPressed: onBackPressed,
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back',
                      )
                    : Image.asset(
                        'assets/images/logo.png',
                        key: const Key('startup-flow-logo'),
                        width: 40,
                        height: 40,
                      ),
              ),
              const Spacer(),
              Text(title, style: textTheme.displaySmall),
              const SizedBox(height: 16),
              Text(body, style: textTheme.bodyLarge),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPrimaryPressed,
                  child: Text(primaryLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Create the flow screen**

Implement `StartupFlowScreen` with concrete copy and navigation:

```dart
class StartupFlowScreen extends ConsumerWidget {
  const StartupFlowScreen({required this.step, super.key});

  final StartupStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = _copyFor(step);
    return StartupStepPage(
      title: copy.title,
      body: copy.body,
      primaryLabel: copy.primaryLabel,
      canGoBack: step != StartupStep.tasks,
      onBackPressed: () => context.pop(),
      onPrimaryPressed: () async {
        final next = step.next;
        if (next != null) {
          await context.push(next.routePath);
          return;
        }
        await ref
            .read(settingsControllerProvider)
            .setStartupFlowCompleted(true);
        if (context.mounted) {
          context.go('/today');
        }
      },
    );
  }
}
```

Use this copy:

```dart
StartupStep.tasks => _StartupCopy(
  title: 'Plan your day',
  body: 'Keep Today, Upcoming, and Lists tidy before the work starts.',
  primaryLabel: 'Next',
),
StartupStep.focus => _StartupCopy(
  title: 'Protect focus time',
  body: 'Attach timers to important tasks or start a standalone focus run.',
  primaryLabel: 'Next',
),
StartupStep.done => _StartupCopy(
  title: 'SyncTask is ready',
  body: 'Your tasks stay local, fast, and ready when you are.',
  primaryLabel: 'Start',
),
```

- [ ] **Step 6: Run test to verify it passes**

Run:

```powershell
flutter test test/features/startup/startup_flow_screen_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```powershell
git add lib/features/startup test/features/startup
git commit -m "feat: add startup flow screens"
```

---

### Task 3: Add Smooth Route Transitions

**Files:**
- Modify: `lib/core/routing/app_router.dart`
- Test: `test/core/routing/app_router_test.dart`

**Interfaces:**
- Produces: `_fadeSlidePage({required Widget child, required GoRouterState state})`
- Consumes: `CustomTransitionPage<void>`

- [ ] **Step 1: Add a router test for transition pages**

In `test/core/routing/app_router_test.dart`, add a widget test that starts at `/startup/tasks`, taps `Next`, and expects the route to reach `/startup/focus` after animation settles:

```dart
testWidgets('startup routes animate between screens', (tester) async {
  final router = appRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository.memory()),
      ],
      child: MaterialApp.router(
        theme: buildSyncTaskTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );

  router.go('/startup/tasks');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pump(const Duration(milliseconds: 120));

  expect(find.text('Plan your day'), findsOneWidget);
  expect(find.text('Protect focus time'), findsOneWidget);

  await tester.pumpAndSettle();
  expect(router.routeInformationProvider.value.uri.path, '/startup/focus');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
flutter test test/core/routing/app_router_test.dart
```

Expected: FAIL until startup routes and transition pages are registered.

- [ ] **Step 3: Register startup routes**

In `lib/core/routing/app_router.dart`, import the startup screen and step:

```dart
import '../../features/startup/domain/startup_step.dart';
import '../../features/startup/screens/startup_flow_screen.dart';
```

Add routes before the `ShellRoute`:

```dart
GoRoute(
  path: '/startup/tasks',
  pageBuilder: (context, state) => _fadeSlidePage(
    state: state,
    child: const StartupFlowScreen(step: StartupStep.tasks),
  ),
),
GoRoute(
  path: '/startup/focus',
  pageBuilder: (context, state) => _fadeSlidePage(
    state: state,
    child: const StartupFlowScreen(step: StartupStep.focus),
  ),
),
GoRoute(
  path: '/startup/done',
  pageBuilder: (context, state) => _fadeSlidePage(
    state: state,
    child: const StartupFlowScreen(step: StartupStep.done),
  ),
),
```

- [ ] **Step 4: Add the transition helper**

Add this private helper at the bottom of `app_router.dart`:

```dart
CustomTransitionPage<void> _fadeSlidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```powershell
flutter test test/core/routing/app_router_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```powershell
git add lib/core/routing test/core/routing
git commit -m "feat: animate startup flow routes"
```

---

### Task 4: Launch Startup Flow From Splash

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/core/routing/app_router.dart`
- Modify: `lib/features/splash/screens/splash_screen.dart`
- Test: `test/core/routing/app_router_test.dart`
- Test: `test/app_smoke_test.dart`

**Interfaces:**
- Updates: `GoRouter appRouter({SettingsRepository? settingsRepository})` or `GoRouter appRouter()`
- Consumes: `SettingsController.load()`
- Produces: splash navigation target `/startup/tasks` for incomplete startup and `/today` for completed startup.

- [ ] **Step 1: Write splash behavior tests**

Update the existing splash test in `test/core/routing/app_router_test.dart` so it expects startup flow first:

```dart
testWidgets('splash opens startup flow before Today on first launch', (
  tester,
) async {
  final router = appRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository.memory()),
      ],
      child: MaterialApp.router(
        theme: buildSyncTaskTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );

  expect(find.byKey(const Key('app-splash-logo')), findsOneWidget);

  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();

  expect(router.routeInformationProvider.value.uri.path, '/startup/tasks');
  expect(find.text('Plan your day'), findsOneWidget);
});
```

Add a completed-user test:

```dart
testWidgets('splash skips startup flow after completion', (tester) async {
  final repository = SettingsRepository.memory();
  await SettingsController(repository).setStartupFlowCompleted(true);
  final router = appRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        theme: buildSyncTaskTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );

  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();

  expect(router.routeInformationProvider.value.uri.path, '/today');
  expect(find.text('Today'), findsOneWidget);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run:

```powershell
flutter test test/core/routing/app_router_test.dart test/app_smoke_test.dart
```

Expected: FAIL because splash currently always calls `context.go('/today')`.

- [ ] **Step 3: Inject settings access into splash**

Convert `SplashScreen` from `StatefulWidget` to `ConsumerStatefulWidget`, import Riverpod and settings controller, and replace the timer callback with:

```dart
Future<void> _openNextScreen() async {
  final settings = await ref.read(settingsControllerProvider).load();
  if (!mounted) {
    return;
  }
  context.go(
    settings.hasCompletedStartupFlow ? '/today' : '/startup/tasks',
  );
}
```

Keep the existing two-second delay:

```dart
_timer = Timer(_delay, _openNextScreen);
```

Use `context.go` here because splash is transient. Back from `/startup/tasks` should leave the app instead of returning to a timed splash that can navigate forward again.

- [ ] **Step 4: Update app bootstrap if needed**

If production startup does not already override `sharedPreferencesProvider`, initialize shared preferences before `runApp` in `lib/main.dart` and pass the provider override into `SyncTaskApp`:

```dart
final preferences = await SharedPreferences.getInstance();
runApp(SyncTaskApp(sharedPreferences: preferences));
```

Then update `SyncTaskApp` so its `ProviderScope` overrides:

```dart
sharedPreferencesProvider.overrideWithValue(sharedPreferences),
```

If this wiring already exists by the time the task is implemented, keep the current bootstrap pattern and only ensure `SplashScreen` can read `settingsControllerProvider`.

- [ ] **Step 5: Update smoke expectations**

Change `test/app_smoke_test.dart` so first launch expects startup flow after splash:

```dart
expect(find.text('Plan your day'), findsOneWidget);
```

Add a short flow completion path:

```dart
await tester.tap(find.text('Next'));
await tester.pumpAndSettle();
await tester.tap(find.text('Next'));
await tester.pumpAndSettle();
await tester.tap(find.text('Start'));
await tester.pumpAndSettle();

expect(find.text('Today'), findsWidgets);
```

- [ ] **Step 6: Run tests to verify they pass**

Run:

```powershell
flutter test test/core/routing/app_router_test.dart test/app_smoke_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```powershell
git add lib/app.dart lib/main.dart lib/features/splash lib/core/routing test/core/routing test/app_smoke_test.dart
git commit -m "feat: launch startup flow from splash"
```

---

### Task 5: Verify Android Back Behavior End To End

**Files:**
- Modify: `test/core/routing/app_router_test.dart`
- Modify: `test/features/startup/startup_flow_screen_test.dart`

**Interfaces:**
- Consumes: `tester.binding.handlePopRoute()`
- Verifies: Android system back pops `/startup/done -> /startup/focus -> /startup/tasks`.

- [ ] **Step 1: Add the full back-stack test**

Add this test to `test/core/routing/app_router_test.dart`:

```dart
testWidgets('android back walks backward through startup flow', (
  tester,
) async {
  final router = appRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(SettingsRepository.memory()),
      ],
      child: MaterialApp.router(
        theme: buildSyncTaskTheme(Brightness.light),
        routerConfig: router,
      ),
    ),
  );

  router.go('/startup/tasks');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  expect(router.routeInformationProvider.value.uri.path, '/startup/done');

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  expect(router.routeInformationProvider.value.uri.path, '/startup/focus');

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  expect(router.routeInformationProvider.value.uri.path, '/startup/tasks');
});
```

- [ ] **Step 2: Add explicit back button parity test**

Add a widget test that taps the visible back icon on `/startup/focus` and expects `/startup/tasks`:

```dart
await tester.tap(find.byTooltip('Back'));
await tester.pumpAndSettle();
expect(router.routeInformationProvider.value.uri.path, '/startup/tasks');
```

- [ ] **Step 3: Run startup and router tests**

Run:

```powershell
flutter test test/features/startup/startup_flow_screen_test.dart test/core/routing/app_router_test.dart
```

Expected: PASS.

- [ ] **Step 4: Run analyzer**

Run:

```powershell
flutter analyze
```

Expected: no new analyzer issues.

- [ ] **Step 5: Commit**

```powershell
git add test/core/routing test/features/startup
git commit -m "test: cover startup flow back navigation"
```

---

### Task 6: Manual Android Verification

**Files:**
- No required source changes.
- Optional: create `docs/release/startup-flow-checklist.md` if the team wants a repeatable manual QA artifact.

**Interfaces:**
- Consumes: Android emulator or device.
- Verifies: real Android back button behavior, transition feel, and returning-user skip.

- [ ] **Step 1: Reset app data**

Run:

```powershell
flutter run
```

On the emulator or device, clear app storage from Android Settings before the first run.

- [ ] **Step 2: Verify first-run path**

Expected path:

```text
Splash logo -> Plan your day -> Protect focus time -> SyncTask is ready -> Today
```

Expected feel:

```text
Splash waits about 2 seconds.
Startup screens fade and slide smoothly.
No bottom navigation appears until Today.
```

- [ ] **Step 3: Verify Android back**

From `SyncTask is ready`, press Android back.

Expected:

```text
SyncTask is ready -> Protect focus time
```

Press Android back again.

Expected:

```text
Protect focus time -> Plan your day
```

Press Android back again.

Expected:

```text
The app exits or background-closes; splash does not re-trigger the flow.
```

- [ ] **Step 4: Verify returning-user path**

Complete the startup flow, close the app, and launch again.

Expected:

```text
Splash logo -> Today
```

- [ ] **Step 5: Run full verification**

Run:

```powershell
flutter test
flutter analyze
```

Expected: all tests pass and analyzer is clean.

- [ ] **Step 6: Commit manual QA notes if created**

```powershell
git add docs/release/startup-flow-checklist.md
git commit -m "docs: add startup flow qa checklist"
```

---

## Self-Review

**Spec coverage:** The plan starts the flow from splash, keeps splash transient, adds smooth transitions, preserves Android back within the flow, skips the flow after completion, and protects existing shell navigation.

**Placeholder scan:** No task uses TBD, TODO, "implement later", or unspecified test coverage. Every code-facing step includes exact files, snippets, commands, and expected results.

**Type consistency:** `StartupStep`, `StartupFlowScreen`, `SettingsController.setStartupFlowCompleted`, and `AppSettings.hasCompletedStartupFlow` are named consistently across tasks.

**Primary risk:** `context.push` must be used between startup flow screens, while `context.go` must be used from splash and final completion. Mixing those up is the most likely way to break Android back behavior.
