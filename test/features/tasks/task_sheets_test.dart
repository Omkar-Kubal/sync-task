import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/features/tasks/widgets/task_edit_sheet.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(theme: buildSyncTaskTheme(Brightness.light), home: Scaffold(body: child));
  }

  testWidgets('edit sheet renders required V1 fields', (tester) async {
    await tester.pumpWidget(wrap(TaskEditSheet(
      title: 'Write report',
      onCancel: () {},
      onDone: () {},
      onStartFocus: () {},
    )));

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

  testWidgets('start focus is disabled when task has no focus timer', (tester) async {
    await tester.pumpWidget(wrap(TaskEditSheet(
      title: 'Write report',
      onCancel: () {},
      onDone: () {},
      onStartFocus: () {},
    )));

    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Start Focus'));
    expect(button.onPressed, isNull);
  });

  testWidgets('start focus is enabled when task has a focus timer', (tester) async {
    var started = false;
    await tester.pumpWidget(wrap(TaskEditSheet(
      title: 'Write report',
      focusDurationMinutes: 45,
      onCancel: () {},
      onDone: () {},
      onStartFocus: () => started = true,
    )));

    await tester.ensureVisible(find.text('Start Focus'));
    await tester.tap(find.text('Start Focus'));
    expect(started, isTrue);
  });
}
