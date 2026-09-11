import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/analytics/analytics_service.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/routing/safe_back_button_dispatcher.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_controller.dart';
import 'core/database/app_database.dart';
import 'features/tasks/providers/task_controller.dart';
import 'features/tasks/widgets/task_list_lifecycle_refresh.dart';
import 'shared/motion/sync_motion.dart';
import 'shared/services/sync_sounds.dart';

class SyncTasksApp extends StatefulWidget {
  const SyncTasksApp({
    this.sharedPreferences,
    this.routeTracker,
    this.appDatabase,
    super.key,
  });

  final SharedPreferences? sharedPreferences;
  final AppAnalyticsRouteTracker? routeTracker;
  final AppDatabase? appDatabase;

  @override
  State<SyncTasksApp> createState() => _SyncTasksAppState();
}

class _SyncTasksAppState extends State<SyncTasksApp> {
  late final GoRouter _router;
  late final SafeBackButtonDispatcher _backButtonDispatcher;
  late final AppAnalyticsRouteTracker _routeTracker;

  @override
  void initState() {
    super.initState();
    _router = appRouter();
    _backButtonDispatcher = SafeBackButtonDispatcher();
    _routeTracker = widget.routeTracker ?? AppAnalyticsRouteTracker();
    _router.routerDelegate.addListener(_trackCurrentScreen);
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackCurrentScreen());
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_trackCurrentScreen);
    _router.dispose();
    unawaited(widget.appDatabase?.close());
    super.dispose();
  }

  void _trackCurrentScreen() {
    unawaited(_routeTracker.track(_router.routeInformationProvider.value.uri));
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        if (widget.sharedPreferences != null)
          sharedPreferencesProvider.overrideWithValue(
            widget.sharedPreferences!,
          ),
        if (widget.appDatabase != null)
          appDatabaseProvider.overrideWithValue(widget.appDatabase!),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: buildSyncTasksTheme(Brightness.light),
        darkTheme: buildSyncTasksTheme(Brightness.dark),
        routerDelegate: _router.routerDelegate,
        routeInformationParser: _router.routeInformationParser,
        routeInformationProvider: _router.routeInformationProvider,
        backButtonDispatcher: _backButtonDispatcher,
        builder: (context, child) => TaskListLifecycleRefresh(
          child: _SoundEffectsBoundary(child: _ThemeModeBoundary(child: child)),
        ),
      ),
    );
  }
}

class _SoundEffectsBoundary extends ConsumerWidget {
  const _SoundEffectsBoundary({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SyncSounds.enabled = ref
        .watch(settingsProvider)
        .maybeWhen(
          data: (settings) => settings.soundEffects,
          orElse: () => true,
        );
    return child ?? const SizedBox.shrink();
  }
}

class _ThemeModeBoundary extends ConsumerWidget {
  const _ThemeModeBoundary({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref
        .watch(settingsProvider)
        .maybeWhen(
          data: (settings) => settings.themeMode,
          orElse: () => ThemeMode.system,
        );
    final brightness = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };

    return AnimatedTheme(
      data: buildSyncTasksTheme(brightness),
      duration: SyncMotion.themeDuration,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
