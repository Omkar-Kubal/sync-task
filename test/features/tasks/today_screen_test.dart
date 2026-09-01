import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/features/tasks/screens/today_screen.dart';

void main() {
  Widget wrap() {
    return MaterialApp(
      theme: buildSyncTaskTheme(Brightness.light),
      home: const TodayScreen(),
    );
  }

  testWidgets('create task button opens the create task sheet', (tester) async {
    await tester.pumpWidget(wrap());

    expect(
      find.widgetWithText(FilledButton, 'Create new task'),
      findsOneWidget,
    );

    await tester.tap(find.text('Create new task'));
    await tester.pumpAndSettle();

    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Today'), findsOneWidget);
  });

  testWidgets('floating create button opens the create task sheet', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();

    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Today'), findsOneWidget);
  });

  testWidgets('selecting Today opens the edit task sheet', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('31 Aug 2026'), findsOneWidget);
  });

  testWidgets('task sheets use the design-system modal veil', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();

    final barrierColors = tester
        .widgetList<ModalBarrier>(find.byType(ModalBarrier))
        .map((barrier) => barrier.color);
    expect(barrierColors, contains(const Color(0xB8000000)));
  });
}
