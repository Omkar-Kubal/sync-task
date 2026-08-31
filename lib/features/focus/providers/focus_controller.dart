import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/providers/task_controller.dart';
import '../data/active_timer_repository.dart';
import '../data/focus_history_repository.dart';
import '../domain/active_focus.dart';
import '../domain/focus_run.dart';
import '../domain/focus_status.dart';

final activeTimerRepositoryProvider = Provider<ActiveTimerRepository>((ref) {
  return ActiveTimerRepository.memory();
});

final focusHistoryRepositoryProvider = Provider<FocusHistoryRepository>((ref) {
  return FocusHistoryRepository(ref.watch(appDatabaseProvider));
});

final focusControllerProvider = Provider<FocusController>((ref) {
  return FocusController(
    activeTimers: ref.watch(activeTimerRepositoryProvider),
    focusHistory: ref.watch(focusHistoryRepositoryProvider),
  );
});

class FocusController {
  FocusController({
    required this.activeTimers,
    required this.focusHistory,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ActiveTimerRepository activeTimers;
  final FocusHistoryRepository focusHistory;
  final DateTime Function() _now;

  ActiveFocus? activeFocus;

  FocusStatus get status => activeFocus?.status ?? FocusStatus.idle;

  Future<void> start({int? taskId, required Duration duration}) async {
    if (duration <= Duration.zero) {
      throw ArgumentError('Focus duration must be greater than zero.');
    }
    if (activeFocus != null && activeFocus!.status != FocusStatus.idle) {
      throw StateError('A Focus timer is already active.');
    }

    final startedAt = _now();
    activeFocus = ActiveFocus(
      taskId: taskId,
      startedAt: startedAt,
      plannedDuration: duration,
      currentEndAt: startedAt.add(duration),
      totalExtension: Duration.zero,
      status: FocusStatus.running,
    );
    await activeTimers.save(activeFocus!);
  }

  Future<void> pause() async {
    final focus = _requireStatus(FocusStatus.running);
    final remaining = focus.currentEndAt!.difference(_now());
    activeFocus = focus.copyWith(
      clearCurrentEndAt: true,
      pausedRemaining: remaining.isNegative ? Duration.zero : remaining,
      status: FocusStatus.paused,
    );
    await activeTimers.save(activeFocus!);
  }

  Future<void> resume() async {
    final focus = _requireStatus(FocusStatus.paused);
    activeFocus = focus.copyWith(
      currentEndAt: _now().add(focus.pausedRemaining!),
      clearPausedRemaining: true,
      status: FocusStatus.running,
    );
    await activeTimers.save(activeFocus!);
  }

  Future<void> stop() async {
    activeFocus = null;
    await activeTimers.clear();
  }

  Future<void> expire() async {
    final focus = _requireStatus(FocusStatus.running);
    activeFocus = focus.copyWith(status: FocusStatus.ringing);
    await activeTimers.save(activeFocus!);
  }

  Future<void> extend(Duration amount) async {
    if (amount <= Duration.zero) {
      throw ArgumentError('Extension must be greater than zero.');
    }
    final focus = _requireStatus(FocusStatus.ringing);
    activeFocus = focus.copyWith(
      currentEndAt: _now().add(amount),
      totalExtension: focus.totalExtension + amount,
      status: FocusStatus.running,
    );
    await activeTimers.save(activeFocus!);
  }

  Future<void> dismissCompletion() async {
    final focus = activeFocus;
    if (focus == null) {
      return;
    }
    if (focus.status != FocusStatus.ringing) {
      throw StateError('Focus completion can only be dismissed while ringing.');
    }
    if (!focus.completionRecorded) {
      final completedAt = _now();
      await focusHistory.insertCompletedRun(
        FocusRun(
          taskId: focus.taskId,
          startedAt: focus.startedAt,
          completedAt: completedAt,
          plannedDuration: focus.plannedDuration,
          actualDuration: focus.plannedDuration + focus.totalExtension,
          wasExtended: focus.totalExtension > Duration.zero,
        ),
      );
    }
    activeFocus = null;
    await activeTimers.clear();
  }

  Future<void> restore() async {
    activeFocus = await activeTimers.load();
  }

  ActiveFocus _requireStatus(FocusStatus expected) {
    final focus = activeFocus;
    if (focus == null || focus.status != expected) {
      throw StateError('Expected Focus status $expected but was $status.');
    }
    return focus;
  }
}
