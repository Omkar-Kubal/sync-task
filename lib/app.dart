import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_controller.dart';

class SyncTaskApp extends StatelessWidget {
  const SyncTaskApp({required this.sharedPreferences, super.key});

  final SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: buildSyncTaskTheme(Brightness.light),
        darkTheme: buildSyncTaskTheme(Brightness.dark),
        routerConfig: appRouter(),
      ),
    );
  }
}
