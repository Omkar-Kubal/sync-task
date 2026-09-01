import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/features/settings/screens/settings_screen.dart';
import 'package:sync_task/shared/widgets/sync_grouped_section.dart';

void main() {
  testWidgets('settings screen groups rows into filled rounded sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: const SettingsScreen(),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(SyncGroupedSection), findsNWidgets(3));
  });
}
