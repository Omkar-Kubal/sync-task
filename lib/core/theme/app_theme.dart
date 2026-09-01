import 'package:flutter/material.dart';

import 'synctask_color_scheme.dart';

ThemeData buildSyncTaskTheme(Brightness brightness) {
  final tokens = brightness == Brightness.dark
      ? SyncTaskColorScheme.dark
      : SyncTaskColorScheme.light;
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
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      modalBarrierColor: const Color(0xB8000000),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.controlPrimary,
        disabledBackgroundColor: tokens.textSecondary.withValues(alpha: 0.28),
        foregroundColor: tokens.controlForeground,
        disabledForegroundColor: tokens.controlForeground.withValues(
          alpha: 0.64,
        ),
        minimumSize: const Size(44, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.textPrimary,
        disabledForegroundColor: tokens.textSecondary,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        side: BorderSide(color: tokens.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.textPrimary,
        disabledForegroundColor: tokens.textSecondary,
        minimumSize: const Size.square(44),
        padding: EdgeInsets.zero,
        side: BorderSide(color: tokens.divider),
        shape: const CircleBorder(),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: tokens.controlPrimary,
      foregroundColor: tokens.controlForeground,
      shape: const CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surfaceSecondary,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: textTheme.bodyLarge?.copyWith(color: tokens.textSecondary),
      hintStyle: textTheme.bodyLarge?.copyWith(color: tokens.textSecondary),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: tokens.textPrimary,
      textColor: tokens.textPrimary,
      minLeadingWidth: 36,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        color: tokens.textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: tokens.textSecondary,
        letterSpacing: 0,
      ),
    ),
  );
}
