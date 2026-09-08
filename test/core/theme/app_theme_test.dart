import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/core/theme/synctasks_color_scheme.dart';

void main() {
  test('light theme uses New Design typography and monochrome tokens', () {
    final theme = buildSyncTasksTheme(Brightness.light);
    final colors = theme.extension<SyncTasksColorScheme>()!;

    expect(colors.scaffold, const Color(0xFFF2F2F7));
    expect(colors.surface, const Color(0xFFFFFFFF));
    expect(colors.textPrimary, const Color(0xFF000000));
    expect(colors.controlPrimary, const Color(0xFF000000));
    expect(colors.controlForeground, const Color(0xFFFFFFFF));
    expect(theme.textTheme.displayLarge!.fontFamily, 'Poppins');
    expect(theme.textTheme.displayMedium!.fontFamily, 'Poppins');
    expect(theme.textTheme.displaySmall!.fontFamily, 'Poppins');
    expect(theme.textTheme.titleLarge!.fontFamily, 'Poppins');
    expect(theme.textTheme.headlineMedium!.fontFamily, 'Geist');
    expect(theme.textTheme.titleMedium!.fontFamily, 'Geist');
    expect(theme.textTheme.bodyLarge!.fontFamily, 'Geist');
    expect(theme.textTheme.labelLarge!.fontFamily, 'Geist');
    expect(theme.textTheme.displayLarge!.fontSize, 64);
    expect(theme.textTheme.displayLarge!.fontWeight, FontWeight.w700);
    expect(theme.textTheme.titleLarge!.fontSize, 29);
    expect(theme.textTheme.titleLarge!.letterSpacing, 0);
    expect(theme.textTheme.bodyLarge!.fontSize, 16);
  });

  test('light theme applies New Design component defaults', () {
    final theme = buildSyncTasksTheme(Brightness.light);

    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.inputDecorationTheme.fillColor, const Color(0xFFFFFFFF));
    expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    expect(theme.bottomSheetTheme.modalBarrierColor, const Color(0xB8000000));
    expect(theme.dividerTheme.color, const Color(0xFFE5E5EA));

    final outlinedShape = theme.outlinedButtonTheme.style!.shape!.resolve({});
    expect(outlinedShape, isA<RoundedRectangleBorder>());
    expect(
      (outlinedShape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(18),
    );

    final filledShape = theme.filledButtonTheme.style!.shape!.resolve({});
    expect(
      (filledShape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(18),
    );

    final sheetShape = theme.bottomSheetTheme.shape;
    expect(sheetShape, isA<RoundedRectangleBorder>());
    expect(
      (sheetShape! as RoundedRectangleBorder).borderRadius,
      const BorderRadius.vertical(top: Radius.circular(28)),
    );
  });

  test('dark theme reverses primary control contrast', () {
    final theme = buildSyncTasksTheme(Brightness.dark);
    final colors = theme.extension<SyncTasksColorScheme>()!;

    expect(colors.scaffold, const Color(0xFF000000));
    expect(colors.surface, const Color(0xFF1C1C1E));
    expect(colors.textSecondary, const Color(0xFFA1A1AA));
    expect(colors.divider, const Color(0xFF48484A));
    expect(colors.controlPrimary, const Color(0xFFFFFFFF));
    expect(colors.controlForeground, const Color(0xFF000000));
  });
}


