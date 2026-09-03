import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:synctask/core/database/app_database.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/tasks/data/task_repository.dart';
import 'package:synctask/features/tasks/domain/task.dart';
import 'package:synctask/features/tasks/providers/task_controller.dart';
import 'package:synctask/features/tasks/screens/upcoming_screen.dart';

void main() {
  late AppDatabase db;
  late TaskController controller;

  setUp(() {
    db = AppDatabase.memory();
    controller = TaskController(TaskRepository(db));
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: const UpcomingScreen(),
      ),
    );
  }

  testWidgets('upcoming screen matches compact mockup chrome', (tester) async {
    await tester.pumpWidget(wrap());

    final now = DateTime.now();
    expect(find.text('Upcoming'), findsOneWidget);
    expect(
      find.text(
        '${DateFormat('MMM d').format(now)} · Today · ${DateFormat('EEEE').format(now)}',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('More options'), findsOneWidget);
    expect(find.bySemanticsLabel('Create task'), findsOneWidget);

    final titleText = tester.widget<Text>(find.text('Upcoming'));
    expect(titleText.style?.fontSize, 40);
    expect(
      tester.getSize(find.bySemanticsLabel('More options')),
      const Size(40, 40),
    );
  });

  testWidgets('upcoming title sits in the top row like Today', (tester) async {
    await tester.pumpWidget(wrap());

    final titleTop = tester.getTopLeft(find.text('Upcoming')).dy;
    final titleLeft = tester.getTopLeft(find.text('Upcoming')).dx;
    final menuTop = tester.getTopLeft(find.bySemanticsLabel('More options')).dy;

    expect(titleLeft, 20);
    expect(titleTop, 12);
    expect(menuTop, 12);
  });

  testWidgets('upcoming screen renders real tasks as compact rows', (
    tester,
  ) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await controller.create(
      TaskDraft(
        title: 'Test1',
        scheduledDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Test1'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.byKey(const Key('task-row-checkbox')), findsOneWidget);
    expect(find.text('No upcoming tasks'), findsNothing);
  });

  testWidgets('upcoming screen includes tasks scheduled for today', (
    tester,
  ) async {
    final now = DateTime.now();
    await controller.create(
      TaskDraft(
        title: 'Today task',
        scheduledDate: DateTime(now.year, now.month, now.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Today task'), findsOneWidget);
    expect(find.text('No upcoming tasks'), findsNothing);
  });

  testWidgets('upcoming task title can be edited from the sheet', (
    tester,
  ) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await controller.create(
      TaskDraft(
        title: 'Test1',
        scheduledDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      ),
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test1'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('edit-task-title-field')),
      'Test2',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Test2'), findsOneWidget);
    expect(find.text('Test1'), findsNothing);
  });
}
