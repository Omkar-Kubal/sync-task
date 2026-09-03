import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/tasks/domain/recurrence_type.dart';
import 'package:synctask/features/tasks/widgets/task_create_sheet.dart';
import 'package:synctask/features/tasks/widgets/task_edit_sheet.dart';
import 'package:synctask/shared/sheets/app_bottom_sheet.dart';

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

  testWidgets('create sheet uses compact outlined title input chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TaskCreateSheet(onSubmit: (_) {}, onTodaySelected: () {})),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.decoration!.border, isA<OutlineInputBorder>());
    expect(textField.decoration!.filled, isTrue);
    expect(textField.decoration!.labelText, isNull);
    expect(textField.decoration!.hintText, 'Task title');
    expect(textField.style?.fontSize, 16);
    expect(tester.getSize(find.byType(TextField)).height, 48);
  });

  testWidgets('create sheet uses home two compact composer sizing', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TaskCreateSheet(onSubmit: (_) {}, onTodaySelected: () {})),
    );

    expect(tester.getSize(find.byType(AppBottomSheet)).height, 176);
    expect(
      tester.getSize(find.bySemanticsLabel('Submit task')),
      const Size(44, 44),
    );
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
    expect(find.byKey(const Key('edit-task-title-field')), findsOneWidget);
    expect(find.text('Task title'), findsNothing);
  });

  testWidgets('edit sheet quick dates time focus and repeat save updates', (
    tester,
  ) async {
    TaskEditUpdate? saved;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          onCancel: () {},
          onDone: () {},
          onStartFocus: () {},
          onSave: (update) async => saved = update,
        ),
      ),
    );

    await tester.tap(find.text('Tomorrow'));
    await tester.ensureVisible(find.text('Time'));
    await tester.tap(find.byKey(const ValueKey('Enable task time')));
    await tester.pumpAndSettle();
    expect(find.text('Time options'), findsOneWidget);

    await tester.ensureVisible(find.text('Focus Timer'));
    await tester.tap(find.byKey(const ValueKey('Enable focus timer')));
    await tester.pumpAndSettle();
    expect(find.text('Focus timer options'), findsOneWidget);

    await tester.ensureVisible(find.text('Weekly'));
    await tester.tap(find.text('Weekly'));
    await tester.ensureVisible(find.text('Done'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.scheduledDate, isNotNull);
    expect(saved!.scheduledTime, isNotNull);
    expect(saved!.focusDurationMinutes, 25);
    expect(saved!.recurrenceType, RecurrenceType.weekly);
  });

  testWidgets('turning time off hides time options before saving', (
    tester,
  ) async {
    TaskEditUpdate? saved;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          scheduledDate: DateTime(2026, 9, 1),
          scheduledTime: DateTime(2026, 9, 1, 9),
          onCancel: () {},
          onDone: () {},
          onStartFocus: () {},
          onSave: (update) async => saved = update,
        ),
      ),
    );

    expect(find.text('Time options'), findsOneWidget);

    await tester.ensureVisible(find.text('Time'));
    await tester.tap(find.byKey(const ValueKey('Disable task time')));
    await tester.pumpAndSettle();
    expect(find.text('Time options'), findsNothing);

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(saved!.scheduledTime, isNull);
  });

  testWidgets('edit sheet stays below the middle of the screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          focusDurationMinutes: 45,
          onCancel: () {},
          onDone: () {},
          onStartFocus: () {},
        ),
      ),
    );

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;

    expect(
      tester.getSize(find.byType(AppBottomSheet)).height,
      screenHeight * 0.58,
    );
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
          (decoration) => decoration.borderRadius == BorderRadius.circular(24),
        );

    expect(groupedSections.length, greaterThanOrEqualTo(3));
    expect(
      groupedSections.every(
        (decoration) => decoration.color == const Color(0xFFFFFFFF),
      ),
      isTrue,
    );
    expect(
      groupedSections.every(
        (decoration) => decoration.border?.top.color == const Color(0xFFE5E5EA),
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
