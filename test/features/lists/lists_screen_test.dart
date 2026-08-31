import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/features/lists/screens/lists_screen.dart';

void main() {
  testWidgets('lists screen renders V1 organization hub', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSyncTaskTheme(Brightness.light),
      home: const ListsScreen(),
    ));

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
}
