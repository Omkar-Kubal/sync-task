import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/database/app_database.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/tasks/screens/today_screen.dart';
import 'package:synctask/features/tasks/providers/task_controller.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap({Brightness brightness = Brightness.light}) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: buildSyncTaskTheme(brightness),
        home: const TodayScreen(),
      ),
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

  testWidgets('empty home state matches the mockup content and actions', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('No tasks found'), findsOneWidget);
    expect(find.text("Looks like you're all clear for today."), findsOneWidget);
    expect(find.text('Create a task to get started.'), findsOneWidget);
    expect(find.bySemanticsLabel('More options'), findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsNothing);
  });

  testWidgets('home chrome stays compact at the top of Android screens', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    final titleText = tester.widget<Text>(find.text('Today'));
    final dateText = tester.widget<Text>(find.text('${DateTime.now().day}'));
    final menuSize = tester.getSize(find.bySemanticsLabel('More options'));

    expect(titleText.style?.fontSize, 30);
    expect(dateText.style?.fontSize, 22);
    expect(menuSize, const Size(40, 40));
  });

  testWidgets('more options opens and dismisses the home menu', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('More options'));
    await tester.pumpAndSettle();

    expect(find.text('View'), findsOneWidget);
    expect(find.text('Select tasks'), findsOneWidget);

    await tester.tapAt(const Offset(16, 16));
    await tester.pumpAndSettle();

    expect(find.text('View'), findsNothing);
    expect(find.text('Select tasks'), findsNothing);
  });

  testWidgets('create task button uses compact Android sizing', (tester) async {
    await tester.pumpWidget(wrap());

    final button = find.widgetWithText(FilledButton, 'Create new task');
    final buttonText = tester.widget<Text>(find.text('Create new task'));

    expect(tester.getSize(button), const Size(160, 40));
    expect(buttonText.style?.fontSize, 14);
  });

  testWidgets('create task button label remains visible in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(brightness: Brightness.dark));

    final buttonText = tester.widget<Text>(find.text('Create new task'));

    expect(buttonText.style?.color, const Color(0xFF000000));
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

  testWidgets('submitting a task creates it in the Today list', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Plan sprint');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    expect(find.text('Plan sprint'), findsOneWidget);
    expect(find.text('No tasks found'), findsNothing);
  });

  testWidgets('editing a task title updates the Today list', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Plan sprint');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plan sprint'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.text('Task title'), findsNothing);
    expect(find.byKey(const Key('edit-task-title-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('edit-task-title-field')),
      'Plan launch',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Plan launch'), findsOneWidget);
    expect(find.text('Plan sprint'), findsNothing);
  });

  testWidgets('tapping the task completion circle removes it from Today', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.bySemanticsLabel('Create task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Plan sprint');
    await tester.tap(find.bySemanticsLabel('Submit task'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('task-row-checkbox-button')));
    await tester.pumpAndSettle();

    expect(find.text('Plan sprint'), findsNothing);
    expect(find.text('No tasks found'), findsOneWidget);
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
