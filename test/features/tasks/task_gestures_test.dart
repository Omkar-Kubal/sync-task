import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/tasks/widgets/task_row.dart';

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

  testWidgets('task row checkbox completes the task without opening it', (
    tester,
  ) async {
    var completed = false;
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: Scaffold(
          body: TaskRow(
            title: 'Write report',
            metadata: 'Inbox',
            onTap: () => opened = true,
            onComplete: () => completed = true,
            onDelete: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('task-row-checkbox-button')));

    expect(completed, isTrue);
    expect(opened, isFalse);
  });

  testWidgets('task row matches compact checkbox and folder style', (
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

    final checkbox = tester.widget<Container>(
      find.byKey(const Key('task-row-checkbox')),
    );
    final decoration = checkbox.decoration! as BoxDecoration;
    final titleText = tester.widget<Text>(find.text('Write report'));
    final folderText = tester.widget<Text>(find.text('Inbox'));

    expect(
      tester.getSize(find.byKey(const Key('task-row-checkbox'))),
      const Size(22, 22),
    );
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.border?.top.width, 1.8);
    expect(decoration.border?.top.color, const Color(0xFF000000));
    expect(titleText.style?.fontSize, 15);
    expect(folderText.style?.fontSize, 11);
  });
}
