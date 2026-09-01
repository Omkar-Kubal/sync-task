import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/features/tasks/widgets/task_create_sheet.dart';
import 'package:sync_task/features/tasks/widgets/task_edit_sheet.dart';
import 'package:sync_task/shared/sheets/app_bottom_sheet.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: buildSyncTaskTheme(Brightness.light),
      home: Scaffold(body: child),
    );
  }

  testWidgets('create sheet renders task title and quick selectors', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TaskCreateSheet(onSubmit: (_) {}, onTodaySelected: () {})),
    );

    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Today'), findsOneWidget);
    expect(find.bySemanticsLabel('Flag task'), findsOneWidget);
  });

  testWidgets('create sheet uses borderless large title input chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TaskCreateSheet(onSubmit: (_) {}, onTodaySelected: () {})),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.decoration!.border, isNull);
    expect(textField.decoration!.filled, isFalse);
    expect(textField.decoration!.labelText, isNull);
    expect(textField.decoration!.hintText, 'Task title');
    expect(textField.style?.fontSize, 28);
  });

  testWidgets('create sheet notifies when Today is selected', (tester) async {
    var selectedToday = false;
    await tester.pumpWidget(
      wrap(
        TaskCreateSheet(
          onSubmit: (_) {},
          onTodaySelected: () => selectedToday = true,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));

    expect(selectedToday, isTrue);
  });

  testWidgets('edit sheet renders required V1 fields', (tester) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          onCancel: () {},
          onDone: () {},
          onStartFocus: () {},
        ),
      ),
    );

    for (final text in [
      'Cancel',
      'Done',
      'Task title',
      'Tomorrow',
      'Next Week',
      'No Date',
      'Date',
      'Time',
      'Focus Timer',
      'Reminder',
      'Repeat',
      'Start Focus',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('edit sheet groups controls into filled rounded sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          onCancel: () {},
          onDone: () {},
          onStartFocus: () {},
        ),
      ),
    );

    final groupedSections = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .where(
          (decoration) => decoration.borderRadius == BorderRadius.circular(28),
        );

    expect(groupedSections.length, greaterThanOrEqualTo(3));
    expect(
      groupedSections.every(
        (decoration) => decoration.color == const Color(0xFFFFFFFF),
      ),
      isTrue,
    );
  });

  testWidgets('start focus is disabled when task has no focus timer', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          onCancel: () {},
          onDone: () {},
          onStartFocus: () {},
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start Focus'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('start focus is enabled when task has a focus timer', (
    tester,
  ) async {
    var started = false;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          focusDurationMinutes: 45,
          onCancel: () {},
          onDone: () {},
          onStartFocus: () => started = true,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Start Focus'));
    await tester.tap(find.text('Start Focus'));
    expect(started, isTrue);
  });
}
