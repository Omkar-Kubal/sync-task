import 'package:flutter/material.dart';

import 'synctasks_color_scheme.dart';
import 'sync_typography.dart';

ThemeData buildSyncTasksTheme(Brightness brightness) {
  final tokens = brightness == Brightness.dark
      ? SyncTasksColorScheme.dark
      : SyncTasksColorScheme.light;
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
  final typography = SyncTypography.forColors(
    textPrimary: tokens.textPrimary,
    textSecondary: tokens.textSecondary,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.scaffold,
    fontFamily: SyncTypography.fontFamily,
    fontFamilyFallback: const ['Roboto', 'Segoe UI', 'Helvetica', 'Arial'],
    extensions: const <ThemeExtension<dynamic>>[
      SyncTasksColorScheme.light,
      SyncTasksColorScheme.dark,
    ],
  );

  final textTheme = TextTheme(
    displayLarge: typography.heroMetric,
    displayMedium: typography.amountInput,
    displaySmall: typography.pageTitle,
    headlineLarge: typography.pageTitle,
    headlineMedium: typography.cardTitle,
    headlineSmall: typography.bodyTitle,
    titleLarge: typography.pageTitle,
    titleMedium: typography.bodyTitle,
    titleSmall: typography.rowTitle,
    bodyLarge: typography.bodyTitle,
    bodyMedium: typography.rowTitle,
    bodySmall: typography.supporting,
    labelLarge: typography.button,
    labelMedium: typography.action,
    labelSmall: typography.chartLabel,
  );

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[tokens, typography],
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.scaffold,
      foregroundColor: tokens.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: typography.pageTitle,
    ),
    textTheme: textTheme,
    iconTheme: IconThemeData(color: tokens.textPrimary),
    dividerTheme: DividerThemeData(color: tokens.divider, thickness: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      modalBarrierColor: const Color(0xB8000000),
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
        textStyle: typography.button,
        minimumSize: const Size(44, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: typography.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(textStyle: typography.action),
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
      fillColor: tokens.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: tokens.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: tokens.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: tokens.textPrimary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: tokens.destructive),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: tokens.destructive),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: typography.supporting,
      hintStyle: typography.supporting,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: tokens.textPrimary,
      textColor: tokens.textPrimary,
      minLeadingWidth: 36,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      titleTextStyle: typography.rowTitle,
      subtitleTextStyle: typography.supporting,
    ),
  );
}
