import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/features/tasks/widgets/task_row.dart';

void main() {
  testWidgets('task row exposes complete and delete semantic actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            metadata: 'Inbox',
            onTap: () {},
            onComplete: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Write report'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(TaskRow)),
      matchesSemantics(
        label: 'Write report, Inbox',
        isButton: true,
        hasTapAction: true,
        hasDismissAction: true,
      ),
    );
  });

  testWidgets('task row uses a filled rounded-square icon well', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            metadata: 'Inbox',
            onTap: () {},
            onComplete: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    final iconWell = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (container) =>
              container.constraints ==
              const BoxConstraints.tightFor(width: 52, height: 52),
        )
        .single;
    final decoration = iconWell.decoration! as BoxDecoration;

    expect(decoration.color, const Color(0xFFE5E5EA));
    expect(decoration.borderRadius, BorderRadius.circular(16));
  });
}
