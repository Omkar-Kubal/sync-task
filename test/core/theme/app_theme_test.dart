import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/core/theme/synctask_color_scheme.dart';

void main() {
  test('light theme uses monochrome SyncTask tokens', () {
    final theme = buildSyncTaskTheme(Brightness.light);
    final colors = theme.extension<SyncTaskColorScheme>()!;

    expect(colors.scaffold, const Color(0xFFF2F2F7));
    expect(colors.surface, const Color(0xFFFFFFFF));
    expect(colors.textPrimary, const Color(0xFF000000));
    expect(colors.controlPrimary, const Color(0xFF000000));
    expect(colors.controlForeground, const Color(0xFFFFFFFF));
    expect(theme.textTheme.titleLarge!.letterSpacing, 0);
  });

  test('dark theme reverses primary control contrast', () {
    final theme = buildSyncTaskTheme(Brightness.dark);
    final colors = theme.extension<SyncTaskColorScheme>()!;

    expect(colors.scaffold, const Color(0xFF000000));
    expect(colors.surface, const Color(0xFF1C1C1E));
    expect(colors.controlPrimary, const Color(0xFFFFFFFF));
    expect(colors.controlForeground, const Color(0xFF000000));
  });
}
