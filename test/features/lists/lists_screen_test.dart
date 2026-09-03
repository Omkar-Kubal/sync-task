import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/lists/screens/lists_screen.dart';

void main() {
  Future<void> useTallViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('lists screen matches the mockup organization hub', (
    tester,
  ) async {
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
      'MY FOLDERS',
      'Inbox',
      'REMINDERS',
      'NOTION',
      'Notion — Coming Soon',
    ]) {
      expect(find.text(text), findsWidgets);
    }

    expect(find.text('Lists'), findsNothing);
    expect(find.bySemanticsLabel('More list options'), findsOneWidget);
    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    expect(find.bySemanticsLabel('Open All list'), findsOneWidget);
    expect(find.bySemanticsLabel('Open Inbox list'), findsOneWidget);
    expect(find.text('Rename Folder'), findsNothing);
  });

  testWidgets('lists screen uses mockup card grouping', (tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: const ListsScreen(),
      ),
    );

    expect(find.byKey(const Key('lists-primary-section')), findsOneWidget);
    expect(find.byKey(const Key('lists-inbox-section')), findsOneWidget);
    expect(find.byKey(const Key('lists-reminders-section')), findsOneWidget);
    expect(find.byKey(const Key('lists-notion-section')), findsOneWidget);
  });
}
