import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/tasks/providers/folders_provider.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/tasks/domain/recurrence_type.dart';
import 'package:synctasks/features/tasks/widgets/task_create_sheet.dart';
import 'package:synctasks/features/tasks/widgets/task_edit_sheet.dart';
import 'package:synctasks/shared/sheets/app_bottom_sheet.dart';

void main() {
  Widget wrap(Widget child, {List overrides = const []}) {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        ...overrides.cast(),
      ],
      child: MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('create sheet renders task title and quick selectors', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TaskCreateSheet(onSubmit: (_, __) {}, onTodaySelected: (_, __) {})),
    );

    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Today'), findsOneWidget);
    expect(find.bySemanticsLabel('Flag task'), findsNothing);
  });

  testWidgets('create sheet uses compact outlined title input chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(TaskCreateSheet(onSubmit: (_, __) {}, onTodaySelected: (_, __) {})),
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
      wrap(TaskCreateSheet(onSubmit: (_, __) {}, onTodaySelected: (_, __) {})),
    );

    expect(tester.getSize(find.byType(AppBottomSheet)).height, 176);
    expect(
      tester.getSize(find.bySemanticsLabel('Submit task')),
      const Size(44, 44),
    );
  });

  testWidgets('create sheet notifies when Today is selected', (tester) async {
    final haptics = _captureHaptics(tester);
    var selectedToday = false;
    await tester.pumpWidget(
      wrap(
        TaskCreateSheet(
          onSubmit: (_, __) {},
          onTodaySelected: (_, __) => selectedToday = true,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Today'));

    expect(selectedToday, isTrue);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
  });

  testWidgets('create sheet emits haptics when submitting a task', (
    tester,
  ) async {
    final haptics = _captureHaptics(tester);
    var submitted = false;
    await tester.pumpWidget(
      wrap(
        TaskCreateSheet(
          onSubmit: (_, __) => submitted = true,
          onTodaySelected: (_, __) {},
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Submit task'));

    expect(submitted, isTrue);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
    expect(haptics, isNot(contains('HapticFeedbackType.lightImpact')));
  });

  testWidgets('create sheet opens folder choices as a popup menu', (
    tester,
  ) async {
    int? chosenFolderId;
    final folders = [
      Folder(id: 1, name: 'Inbox', sortOrder: 0, createdAt: DateTime(2026)),
      Folder(id: 2, name: 'Work', sortOrder: 1, createdAt: DateTime(2026)),
    ];

    await tester.pumpWidget(
      wrap(
        TaskCreateSheet(
          onSubmit: (title, folderId) => chosenFolderId = folderId,
          onTodaySelected: (_, __) {},
        ),
        overrides: [foldersProvider.overrideWith((ref) async => folders)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Inbox'));
    await tester.pumpAndSettle();

    expect(find.text('Select Folder'), findsNothing);
    expect(find.byType(AppBottomSheet), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(OutlinedButton, 'Work'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Submit task'));
    expect(chosenFolderId, 2);
  });

  testWidgets('edit sheet renders required V1 fields', (tester) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(title: 'Write report', onCancel: () {}, onDone: () {}),
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
      'Duration',
      'Reminder',
      'Repeat',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.text('Focus Timer'), findsNothing);
    expect(find.text('Start Focus'), findsNothing);
    expect(find.byKey(const Key('edit-task-title-field')), findsOneWidget);
    expect(find.text('Task title'), findsNothing);
  });

  testWidgets('edit sheet opens shorter by default', (tester) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(title: 'Write report', onCancel: () {}, onDone: () {}),
      ),
    );

    final sheet = tester.widget<AppBottomSheet>(find.byType(AppBottomSheet));
    expect(sheet.minHeight, 320);
    expect(
      sheet.maxHeight,
      tester.view.physicalSize.height / tester.view.devicePixelRatio * 0.86,
    );
  });

  testWidgets('edit sheet quick dates save immediately and close', (
    tester,
  ) async {
    final haptics = _captureHaptics(tester);
    TaskEditUpdate? saved;
    var done = false;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          onCancel: () {},
          onDone: () => done = true,
          onSave: (update) async => saved = update,
        ),
      ),
    );

    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.scheduledDate, isNotNull);
    expect(done, isTrue);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
  });

  testWidgets('time switch saves time without showing preset options', (
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
          onSave: (update) async => saved = update,
        ),
      ),
    );

    expect(find.text('Time options'), findsNothing);
    expect(find.text('9:00 AM'), findsOneWidget);

    await tester.ensureVisible(find.text('Time'));
    await tester.tap(find.byKey(const ValueKey('Disable task time')));
    await tester.pumpAndSettle();
    expect(find.text('Time options'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    expect(saved!.scheduledTime, isNull);
  });

  testWidgets('duration switch saves without exposing focus controls', (
    tester,
  ) async {
    TaskEditUpdate? saved;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          scheduledDate: DateTime(2026, 9, 1),
          onCancel: () {},
          onDone: () {},
          onSave: (update) async => saved = update,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Duration'));
    await tester.tap(find.byKey(const ValueKey('Enable task duration')));
    await tester.pumpAndSettle();

    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('Focus Timer'), findsNothing);
    expect(find.text('Start Focus'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('edit-task-done-button')));
    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.focusDurationMinutes, 30);
  });

  testWidgets('edit sheet omits focus controls after toggling time', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(
        TaskEditSheet(title: 'Write report', onCancel: () {}, onDone: () {}),
      ),
    );

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;

    expect(
      tester.getSize(find.byType(AppBottomSheet)).height,
      screenHeight * 0.50,
    );

    await tester.tap(find.byKey(const ValueKey('Enable task time')));
    await tester.pumpAndSettle();

    expect(find.text('Time options'), findsNothing);
    expect(find.text('12:00 AM'), findsOneWidget);
    expect(find.text('Focus Timer'), findsNothing);
    expect(find.text('Focus timer options'), findsNothing);
    expect(find.text('Start Focus'), findsNothing);
  });

  testWidgets(
    'edit sheet validates blank titles instead of silently stalling',
    (tester) async {
      var done = false;
      await tester.pumpWidget(
        wrap(
          TaskEditSheet(
            title: 'Write report',
            onCancel: () {},
            onDone: () => done = true,
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('edit-task-title-field')),
        '',
      );
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(done, isFalse);
      expect(find.text('Task title required'), findsNothing);
    },
  );

  testWidgets('reminder row opens preset menu and saves an offset', (
    tester,
  ) async {
    final haptics = _captureHaptics(tester);
    TaskEditUpdate? saved;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          scheduledDate: DateTime(2026, 9, 4),
          scheduledTime: DateTime(2026, 9, 4, 9),
          onCancel: () {},
          onDone: () {},
          onSave: (update) async => saved = update,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Reminder'));
    await tester.tap(find.text('Reminder'));
    await tester.pumpAndSettle();

    expect(find.text('On time'), findsOneWidget);
    expect(find.text('15 minutes before'), findsOneWidget);
    expect(find.text('1 hour before'), findsOneWidget);
    expect(find.text('1 day before (00:00)'), findsOneWidget);
    expect(find.text('1 week before (00:00)'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));

    await tester.tap(find.text('15 minutes before'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Done'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.reminderTime, DateTime(2026, 9, 4, 8, 45));
  });

  testWidgets('custom reminder opens a dedicated bottom sheet', (tester) async {
    TaskEditUpdate? saved;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          scheduledDate: DateTime(2026, 9, 5),
          scheduledTime: DateTime(2026, 9, 5, 14, 57),
          onCancel: () {},
          onDone: () {},
          onSave: (update) async => saved = update,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Reminder'));
    await tester.tap(find.text('Reminder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Reminder'), findsOneWidget);
    expect(find.text('Day'), findsWidgets);
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('Remind on Sep 4 at 2:57 PM'), findsOneWidget);

    await tester.tap(find.byKey(const Key('custom-reminder-done-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('edit-task-done-button')));
    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.reminderTime, DateTime(2026, 9, 4, 14, 57));
  });

  testWidgets('repeat row opens menu and saves selected recurrence', (
    tester,
  ) async {
    TaskEditUpdate? saved;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          scheduledDate: DateTime(2026, 9, 4),
          onCancel: () {},
          onDone: () {},
          onSave: (update) async => saved = update,
        ),
      ),
    );

    expect(find.text('Repeat options'), findsNothing);

    await tester.ensureVisible(find.text('Repeat'));
    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();

    for (final option in ['None', 'Daily', 'Weekly', 'Monthly', 'Custom']) {
      expect(find.text(option), findsWidgets);
    }

    await tester.tap(find.text('Weekly').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('edit-task-done-button')));
    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.recurrenceType, RecurrenceType.weekly);
  });

  testWidgets('edit sheet groups controls into filled borderless sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(title: 'Write report', onCancel: () {}, onDone: () {}),
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
      groupedSections.every((decoration) => decoration.border == null),
      isTrue,
    );
  });
  testWidgets('custom repeat opens custom sheet and saves recurrence', (
    tester,
  ) async {
    TaskEditUpdate? saved;
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Write report',
          scheduledDate: DateTime(2026, 9, 4),
          onCancel: () {},
          onDone: () {},
          onSave: (update) async => saved = update,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Repeat'));
    await tester.tap(find.text('Repeat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Repeat'), findsOneWidget);
    expect(find.text('Every'), findsOneWidget);
    expect(find.text('Task will repeat every day.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('custom-repeat-done-button')));
    await tester.pumpAndSettle();

    expect(find.text('Every day'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('edit-task-done-button')));
    await tester.tap(find.byKey(const Key('edit-task-done-button')));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.recurrenceType, RecurrenceType.daily);
  });
}

List<Object?> _captureHaptics(WidgetTester tester) {
  final calls = <Object?>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add(call.arguments);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}
