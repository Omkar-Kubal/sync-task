import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/database/app_database.dart';
import 'package:synctask/features/focus/data/active_timer_repository.dart';
import 'package:synctask/features/focus/data/focus_history_repository.dart';
import 'package:synctask/features/focus/domain/focus_status.dart';
import 'package:synctask/features/focus/providers/focus_controller.dart';

void main() {
  late AppDatabase db;
  late FocusController controller;
  var now = DateTime(2026, 8, 31, 10);

  setUp(() {
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

  test('runs pause resume stop lifecycle without creating history', () async {
    await controller.start(duration: const Duration(minutes: 25));
    expect(controller.status, FocusStatus.running);

    now = DateTime(2026, 8, 31, 10, 5);
    await controller.pause();
    expect(controller.status, FocusStatus.paused);
    expect(controller.activeFocus!.pausedRemaining, const Duration(minutes: 20));

    await controller.resume();
    expect(controller.status, FocusStatus.running);

    await controller.stop();
    expect(controller.status, FocusStatus.idle);
    expect(await db.select(db.focusHistory).get(), isEmpty);
  });

  test('expiry extension and dismiss create exactly one completed history row', () async {
    await controller.start(taskId: 7, duration: const Duration(minutes: 25));
    now = DateTime(2026, 8, 31, 10, 25);
    await controller.expire();
    expect(controller.status, FocusStatus.ringing);

    await controller.extend(const Duration(minutes: 10));
    expect(controller.status, FocusStatus.running);

    now = DateTime(2026, 8, 31, 10, 35);
    await controller.expire();
    await controller.dismissCompletion();
    await controller.dismissCompletion();

    final rows = await db.select(db.focusHistory).get();
    expect(rows, hasLength(1));
    expect(rows.single.plannedDurationMinutes, 25);
    expect(rows.single.actualDurationMinutes, 35);
    expect(rows.single.wasExtended, isTrue);
  });

  test('rejects invalid focus transitions', () async {
    expect(controller.resume, throwsStateError);

    await controller.start(duration: const Duration(minutes: 5));
    expect(() => controller.start(duration: const Duration(minutes: 5)), throwsStateError);
    expect(() => controller.extend(const Duration(minutes: 5)), throwsStateError);
  });
}
