import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/shared/widgets/app_shell.dart';

void main() {
  testWidgets('app shell renders child and exactly four primary tabs', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSyncTaskTheme(Brightness.light),
      home: AppShell(
        currentIndex: 0,
        onDestinationSelected: (_) {},
        child: const Text('Shell child'),
      ),
    ));

    expect(find.text('Shell child'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Lists'), findsOneWidget);
    expect(find.text('Search'), findsNothing);
    expect(find.text('Insights'), findsNothing);
  });
}
