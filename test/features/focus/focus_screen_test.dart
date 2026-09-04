import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/database/app_database.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/features/focus/data/active_timer_repository.dart';
import 'package:synctask/features/focus/data/focus_history_repository.dart';
import 'package:synctask/features/focus/domain/active_focus.dart';
import 'package:synctask/features/focus/domain/focus_status.dart';
import 'package:synctask/features/focus/providers/focus_controller.dart';
import 'package:synctask/features/focus/screens/focus_screen.dart';
import 'package:synctask/features/tasks/providers/task_controller.dart';

void main() {
  late AppDatabase db;
  late FocusController controller;
  final startedAt = DateTime(2026, 9, 2, 10);
  late DateTime now;

  setUp(() {
    now = startedAt;
    db = AppDatabase.memory();
    controller = FocusController(
      activeTimers: ActiveTimerRepository.memory(),
      focusHistory: FocusHistoryRepository(db),
      now: () => now,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        focusControllerProvider.overrideWithValue(controller),
      ],
      child: MaterialApp(
        theme: buildSyncTaskTheme(Brightness.light),
        home: const FocusScreen(),
      ),
    );
  }

  testWidgets('focus idle screen shows the monochrome set timer dial', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Focus'), findsOneWidget);
    expect(find.bySemanticsLabel('More options'), findsNothing);
    expect(find.byKey(const Key('focus-idle-stopwatch')), findsNothing);
    expect(find.text('Set Timer'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('min'), findsOneWidget);
    expect(find.text('Focus session'), findsOneWidget);
    expect(find.byKey(const Key('focus-duration-dial')), findsOneWidget);
    expect(find.text('View Insights'), findsOneWidget);
    expect(find.text('Streak 0 days'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('15'), findsNothing);
    expect(find.text('45'), findsNothing);
    expect(find.text('60'), findsNothing);
    expect(find.text('Custom'), findsNothing);
    expect(find.text('HH'), findsNothing);
    expect(find.text('MM'), findsNothing);
    expect(find.text('SS'), findsNothing);
    expect(find.text('--:--'), findsNothing);
    expect(find.text('+5'), findsNothing);
    expect(find.text('+10'), findsNothing);
  });

  testWidgets('standalone focus starts the selected dial duration', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    final startButton = tester.widget<IconButton>(
      find.byKey(const Key('focus-start-button')),
    );
    expect(startButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('focus-start-button')));
    await tester.pumpAndSettle();

    expect(
      controller.activeFocus!.plannedDuration,
      const Duration(minutes: 25),
    );
    expect(
      find.bySemanticsLabel('Focus timer progress 100 percent'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('focus-idle-stopwatch')), findsNothing);
    expect(find.text('25:00'), findsOneWidget);
  });

  testWidgets('running focus ring reflects elapsed timer progress', (
    tester,
  ) async {
    controller.activeFocus = ActiveFocus(
      startedAt: startedAt,
      plannedDuration: const Duration(minutes: 10),
      currentEndAt: startedAt.add(const Duration(minutes: 10)),
      totalExtension: Duration.zero,
      status: FocusStatus.running,
    );
    now = startedAt.add(const Duration(minutes: 5));

    await tester.pumpWidget(wrap());

    expect(
      find.bySemanticsLabel('Focus timer progress 50 percent'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('focus-idle-stopwatch')), findsNothing);
    expect(find.text('05:00'), findsOneWidget);
  });

  testWidgets('dragging freely can select any minute on the dial', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    final dialFinder = find.byKey(const Key('focus-duration-dial'));
    final dialCenter = tester.getCenter(dialFinder);
    const radius = 90.0;
    final targetAngle = -math.pi / 2 + (math.pi * 2 * 37 / 60);
    final target = Offset(
      dialCenter.dx + math.cos(targetAngle) * radius,
      dialCenter.dy + math.sin(targetAngle) * radius,
    );

    final gesture = await tester.startGesture(dialCenter);
    await gesture.moveTo(target);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('37'), findsOneWidget);
  });

  testWidgets('reset returns the selected dial duration to default', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    final dialFinder = find.byKey(const Key('focus-duration-dial'));
    final dialCenter = tester.getCenter(dialFinder);
    final gesture = await tester.startGesture(dialCenter);
    await gesture.moveTo(dialCenter + const Offset(0, 90));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('30'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    final startButton = tester.widget<IconButton>(
      find.byKey(const Key('focus-start-button')),
    );
    expect(startButton.onPressed, isNotNull);
    expect(find.text('25'), findsOneWidget);
  });

  testWidgets('focus running screen matches the timer mockup', (tester) async {
    controller.activeFocus = ActiveFocus(
      startedAt: startedAt,
      taskTitle: 'Study',
      plannedDuration: const Duration(minutes: 25),
      currentEndAt: startedAt.add(const Duration(minutes: 25)),
      totalExtension: Duration.zero,
      status: FocusStatus.running,
    );

    await tester.pumpWidget(wrap());

    expect(find.text('Focus'), findsOneWidget);
    expect(find.byKey(const Key('focus-running-ring')), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Task: Study'), findsOneWidget);
    expect(find.text('Streak 0 days'), findsOneWidget);
    expect(find.bySemanticsLabel('Stop focus'), findsOneWidget);
    expect(find.bySemanticsLabel('Resume focus'), findsOneWidget);
    expect(find.bySemanticsLabel('Pause focus'), findsOneWidget);
    expect(find.text('Set Timer'), findsNothing);
  });

  testWidgets('standalone running focus does not show a fake task card', (
    tester,
  ) async {
    controller.activeFocus = ActiveFocus(
      startedAt: startedAt,
      plannedDuration: const Duration(minutes: 15),
      currentEndAt: startedAt.add(const Duration(minutes: 15)),
      totalExtension: Duration.zero,
      status: FocusStatus.running,
    );

    await tester.pumpWidget(wrap());

    expect(find.text('15:00'), findsOneWidget);
    expect(find.text('Task: Study'), findsNothing);
    expect(find.text('Standalone Focus'), findsNothing);
  });

  testWidgets('expired focus shows completion actions', (tester) async {
    controller.activeFocus = ActiveFocus(
      startedAt: DateTime(2026, 9, 2, 9, 30),
      plannedDuration: const Duration(minutes: 25),
      currentEndAt: DateTime(2026, 9, 2, 9, 55),
      totalExtension: Duration.zero,
      status: FocusStatus.ringing,
    );

    await tester.pumpWidget(wrap());

    expect(find.text('Focus Complete'), findsOneWidget);
    expect(find.text('+5 min'), findsOneWidget);
    expect(find.text('+10 min'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });
}
