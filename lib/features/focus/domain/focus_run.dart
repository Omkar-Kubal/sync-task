class FocusRun {
  const FocusRun({
    required this.startedAt,
    required this.completedAt,
    required this.plannedDuration,
    required this.actualDuration,
    required this.wasExtended,
    this.taskId,
  });

  final int? taskId;
  final DateTime startedAt;
  final DateTime completedAt;
  final Duration plannedDuration;
  final Duration actualDuration;
  final bool wasExtended;
}
