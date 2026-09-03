import 'focus_status.dart';

class ActiveFocus {
  const ActiveFocus({
    required this.startedAt,
    required this.plannedDuration,
    required this.totalExtension,
    required this.status,
    this.taskId,
    this.taskTitle,
    this.currentEndAt,
    this.pausedRemaining,
    this.completionRecorded = false,
  });

  final int? taskId;
  final String? taskTitle;
  final DateTime startedAt;
  final Duration plannedDuration;
  final DateTime? currentEndAt;
  final Duration? pausedRemaining;
  final Duration totalExtension;
  final FocusStatus status;
  final bool completionRecorded;

  ActiveFocus copyWith({
    int? taskId,
    String? taskTitle,
    DateTime? startedAt,
    Duration? plannedDuration,
    DateTime? currentEndAt,
    bool clearCurrentEndAt = false,
    Duration? pausedRemaining,
    bool clearPausedRemaining = false,
    Duration? totalExtension,
    FocusStatus? status,
    bool? completionRecorded,
  }) {
    return ActiveFocus(
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      startedAt: startedAt ?? this.startedAt,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      currentEndAt: clearCurrentEndAt
          ? null
          : currentEndAt ?? this.currentEndAt,
      pausedRemaining: clearPausedRemaining
          ? null
          : pausedRemaining ?? this.pausedRemaining,
      totalExtension: totalExtension ?? this.totalExtension,
      status: status ?? this.status,
      completionRecorded: completionRecorded ?? this.completionRecorded,
    );
  }
}
