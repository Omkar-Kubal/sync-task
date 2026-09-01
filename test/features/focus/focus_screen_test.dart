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

  setUp(() {
    db = AppDatabase.memory();
    controller = FocusController(
      activeTimers: ActiveTimerRepository.memory(),
      focusHistory: FocusHistoryRepository(db),
      now: () => startedAt,
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

  testWidgets('focus idle screen matches the set time mockup', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Focus'), findsOneWidget);
    expect(find.bySemanticsLabel('More options'), findsOneWidget);
    expect(find.byKey(const Key('focus-idle-stopwatch')), findsOneWidget);
    expect(find.text('Set time'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('00'), findsNWidgets(2));
    expect(find.text('25'), findsOneWidget);
    expect(find.text('HH'), findsOneWidget);
    expect(find.text('MM'), findsOneWidget);
    expect(find.text('SS'), findsOneWidget);
    expect(find.text('--:--'), findsNothing);
    expect(find.text('+5'), findsNothing);
    expect(find.text('+10'), findsNothing);
  });

  testWidgets('focus running screen matches the timer mockup', (tester) async {
    controller.activeFocus = ActiveFocus(
      startedAt: startedAt,
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
    expect(find.text('Streak 3 days'), findsOneWidget);
    expect(find.bySemanticsLabel('Stop focus'), findsOneWidget);
    expect(find.bySemanticsLabel('Resume focus'), findsOneWidget);
    expect(find.bySemanticsLabel('Pause focus'), findsOneWidget);
    expect(find.text('Set time'), findsNothing);
  });
}
