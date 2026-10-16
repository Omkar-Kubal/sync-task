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
import 'package:synctasks/shared/services/sync_haptics.dart';
import 'package:synctasks/shared/sheets/app_bottom_sheet.dart';

void main() {
  setUp(SyncHaptics.resetForTesting);

  TaskCreateSheet createSheet({
    void Function(String, int?)? onSubmit,
    Future<void> Function(String, int?, TaskEditUpdate)? onSchedule,
    VoidCallback? onScheduledDone,
  }) {
    return TaskCreateSheet(
      key: UniqueKey(),
      onSubmit: onSubmit ?? (_, __) {},
      onSchedule: onSchedule ?? (_, __, ___) async {},
      onScheduledDone: onScheduledDone ?? () {},
    );
  }

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
    await tester.pumpWidget(wrap(createSheet()));

    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Inbox'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Schedule'), findsOneWidget);
    expect(find.bySemanticsLabel('Flag task'), findsNothing);
  });

  testWidgets('create sheet uses compact outlined title input chrome', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(createSheet()));

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
    await tester.pumpWidget(wrap(createSheet()));

    expect(tester.getSize(find.byType(AppBottomSheet)).height, 176);
    final addSize = tester.getSize(find.widgetWithText(FilledButton, 'Add'));
    expect(addSize.width, greaterThanOrEqualTo(78));
    expect(addSize.height, greaterThanOrEqualTo(44));
  });

  testWidgets('Add is disabled until the task has a title', (tester) async {
    await tester.pumpWidget(wrap(createSheet()));
    final addButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Add'),
    );
    expect(addButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'A task');
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Add'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('app bottom sheets use a visible top-edge shadow', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(createSheet()));

    final sheetDecorations = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(AppBottomSheet),
            matching: find.byType(Container),
          ),
        )
        .map((container) => container.decoration)
        .whereType<BoxDecoration>();
    final sheetDecoration = sheetDecorations.firstWhere(
      (decoration) =>
          decoration.borderRadius ==
          const BorderRadius.vertical(top: Radius.circular(28)),
    );
    final shadow = sheetDecoration.boxShadow!.single;

    expect(shadow.blurRadius, greaterThanOrEqualTo(28));
    expect(shadow.offset.dy, lessThanOrEqualTo(-6));
    expect(shadow.color.a, greaterThanOrEqualTo(0.10));
  });

  testWidgets('Schedule opens create options and cancel preserves the draft', (
    tester,
  ) async {
    final haptics = _captureHaptics(tester);
    var scheduled = false;
    var submittedTitle = '';
    await tester.pumpWidget(
      wrap(
        createSheet(
          onSubmit: (title, _) => submittedTitle = title,
          onSchedule: (title, _, __) async {
            scheduled = true;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Draft task');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('New task'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('edit-task-title-field')))
          .controller!
          .text,
      'Draft task',
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(OutlinedButton, 'Schedule'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Draft task',
    );
    expect(scheduled, isFalse);
    expect(submittedTitle, isEmpty);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
  });

  testWidgets('Create saves the scheduled draft exactly once', (tester) async {
    var saveCount = 0;
    var savedTitle = '';
    var doneCount = 0;
    await tester.pumpWidget(
      wrap(
        createSheet(
          onSchedule: (title, _, update) async {
            saveCount++;
            savedTitle = update.title;
          },
          onScheduledDone: () => doneCount++,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Scheduled draft');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Schedule'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create-task-options-button')));
    await tester.pumpAndSettle();
    expect(saveCount, 1);
    expect(doneCount, 1);
    expect(savedTitle, 'Scheduled draft');
  });

  testWidgets('create sheet emits haptics when submitting a task', (
    tester,
  ) async {
    final haptics = _captureHaptics(tester);
    var submitCount = 0;
    var submittedTitle = '';
    await tester.pumpWidget(
      wrap(
        createSheet(
          onSubmit: (title, _) {
            submitCount++;
            submittedTitle = title;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Submit once');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Add'),
      warnIfMissed: false,
    );

    expect(submitCount, 1);
    expect(submittedTitle, 'Submit once');
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
    expect(haptics, isNot(contains('HapticFeedbackType.lightImpact')));
  });

  testWidgets('create sheet opens folder choices as a popup menu', (
    tester,
  ) async {
    int? chosenFolderId;
    var submittedTitle = '';
    final folders = [
      Folder(id: 1, name: 'Inbox', sortOrder: 0, createdAt: DateTime(2026)),
      Folder(id: 2, name: 'Work', sortOrder: 1, createdAt: DateTime(2026)),
    ];

    await tester.pumpWidget(
      wrap(
        createSheet(
          onSubmit: (title, folderId) {
            submittedTitle = title;
            chosenFolderId = folderId;
          },
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

    await tester.enterText(find.byType(TextField), 'Folder task');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Folder task',
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Add'))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    expect(submittedTitle, 'Folder task');
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
    final noDateText = tester.widget<Text>(find.text('No Date'));
    expect(noDateText.style?.color, isNot(const Color(0xFFD92D20)));
  });

  testWidgets('create options are labeled New task and Create', (tester) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title: 'Draft',
          isCreating: true,
          onCancel: () {},
          onDone: () {},
        ),
      ),
    );

    expect(find.text('New task'), findsOneWidget);
    expect(find.text('Create'), findsOneWidget);
    expect(find.byKey(const Key('create-task-options-button')), findsOneWidget);
    expect(find.text('Edit Task'), findsNothing);
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('edit sheet title field wraps long task names', (tester) async {
    await tester.pumpWidget(
      wrap(
        TaskEditSheet(
          title:
              'Prepare the production release checklist and verify every visible surface before submission',
          onCancel: () {},
          onDone: () {},
        ),
      ),
    );

    final textField = tester.widget<TextField>(
      find.byKey(const Key('edit-task-title-field')),
    );
    expect(textField.maxLines, greaterThan(1));
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
  SyncHaptics.resetForTesting();
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add(call.arguments);
      }
      return null;
    },
  );
  addTearDown(() {
    SyncHaptics.resetForTesting();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });
  return calls;
}
