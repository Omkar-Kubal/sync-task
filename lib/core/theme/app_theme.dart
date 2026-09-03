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
    fontFamily: 'Geist',
    fontFamilyFallback: const ['Poppins', 'Segoe UI', 'Helvetica', 'Arial'],
    extensions: const <ThemeExtension<dynamic>>[
      SyncTaskColorScheme.light,
      SyncTaskColorScheme.dark,
    ],
  );

  final textTheme = base.textTheme.apply(
    bodyColor: tokens.textPrimary,
    displayColor: tokens.textPrimary,
    fontFamily: 'Geist',
  );

  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.scaffold,
      foregroundColor: tokens.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.headlineMedium?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    ),
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontFamily: 'Poppins',
        fontSize: 64,
        fontWeight: FontWeight.w700,
        height: 1,
        letterSpacing: 0,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontFamily: 'Poppins',
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: 0,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontFamily: 'Poppins',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.23,
        letterSpacing: 0,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontFamily: 'Poppins',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
        letterSpacing: 0,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontFamily: 'Poppins',
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: 0,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontSize: 12,
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
