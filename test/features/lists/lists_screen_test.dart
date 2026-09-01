import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/lists/screens/lists_screen.dart';
import 'package:synctask/shared/widgets/sync_grouped_section.dart';

void main() {
  Future<void> useTallViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('lists screen renders V1 organization hub', (tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: const ListsScreen(),
      ),
    );

    for (final text in [
      'All',
      'Today',
      'Upcoming',
      'Completed',
      'My Folders',
      'Inbox',
      'Reminders',
      'Notion',
      'Notion - Coming Soon',
    ]) {
      expect(find.text(text), findsWidgets);
    }

    expect(find.text('Rename Folder'), findsNothing);
  });

  testWidgets('lists screen groups rows into filled rounded sections', (
    tester,
  ) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: const ListsScreen(),
      ),
    );

    expect(find.byType(SyncGroupedSection), findsNWidgets(4));
  });
}
