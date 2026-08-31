class InsightsSummary {
  const InsightsSummary({
    required this.todayFocusRuns,
    required this.weekFocusRuns,
    required this.todayFocusedDuration,
    required this.weekFocusedDuration,
    required this.todayCompletedTasks,
    required this.currentStreak,
  });

  final int todayFocusRuns;
  final int weekFocusRuns;
  final Duration todayFocusedDuration;
  final Duration weekFocusedDuration;
  final int todayCompletedTasks;
  final int currentStreak;
}
