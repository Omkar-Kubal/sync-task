import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class SyncTaskApp extends ConsumerWidget {
  const SyncTaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: buildSyncTaskTheme(Brightness.light),
      darkTheme: buildSyncTaskTheme(Brightness.dark),
      routerConfig: appRouter(),
    );
  }
}
