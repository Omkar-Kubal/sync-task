import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/search/screens/search_screen.dart';

void main() {
  testWidgets('search screen filters tasks by title only', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSyncTaskTheme(Brightness.light),
      home: const SearchScreen(
        initialTasks: [
          SearchTaskResult(id: 1, title: 'Write report', metadata: 'Inbox'),
          SearchTaskResult(id: 2, title: 'Plan workout', metadata: 'Today'),
        ],
      ),
    ));

    await tester.enterText(find.byType(TextField), 'report');
    await tester.pump();

    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('Plan workout'), findsNothing);
  });
}
