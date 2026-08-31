import 'package:flutter/material.dart';

import 'synctask_color_scheme.dart';

ThemeData buildSyncTaskTheme(Brightness brightness) {
  final tokens =
      brightness == Brightness.dark ? SyncTaskColorScheme.dark : SyncTaskColorScheme.light;
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: tokens.controlPrimary,
    onPrimary: tokens.controlForeground,
    secondary: tokens.textPrimary,
    onSecondary: tokens.scaffold,
    error: tokens.destructive,
    onError: Colors.white,
    surface: tokens.surface,
    onSurface: tokens.textPrimary,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.scaffold,
    fontFamily: 'Inter',
    extensions: const <ThemeExtension<dynamic>>[
      SyncTaskColorScheme.light,
      SyncTaskColorScheme.dark,
    ],
  );

  final textTheme = base.textTheme.apply(
    bodyColor: tokens.textPrimary,
    displayColor: tokens.textPrimary,
    fontFamily: 'Inter',
  );

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.scaffold,
      foregroundColor: tokens.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    ),
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(letterSpacing: 0),
      displayMedium: textTheme.displayMedium?.copyWith(letterSpacing: 0),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(letterSpacing: 0),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(letterSpacing: 0),
      bodyMedium: textTheme.bodyMedium?.copyWith(letterSpacing: 0),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    ),
    iconTheme: IconThemeData(color: tokens.textPrimary),
    dividerTheme: DividerThemeData(color: tokens.divider, thickness: 1),
  );
}
