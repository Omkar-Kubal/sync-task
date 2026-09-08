class CompletionTrendPoint {
  const CompletionTrendPoint({
    required this.date,
    required this.completedTaskCount,
  });

  final DateTime date;
  final int completedTaskCount;
}

class InsightsSummary {
  const InsightsSummary({
    required this.todayCompletedTasks,
    required this.weekCompletedTasks,
    required this.currentStreak,
    this.previousStreak = 0,
    this.completionTrend = const [],
    this.bestCompletionWeekdayLabel = 'No completion pattern yet',
    this.bestCompletionWeekdayCount = 0,
    this.plannedCompletedTasks = 0,
    this.unplannedCompletedTasks = 0,
    this.plannedCompletionPercent = 0,
  });

  final int todayCompletedTasks;
  final int weekCompletedTasks;
  final int currentStreak;
  final int previousStreak;
  final List<CompletionTrendPoint> completionTrend;
  final String bestCompletionWeekdayLabel;
  final int bestCompletionWeekdayCount;
  final int plannedCompletedTasks;
  final int unplannedCompletedTasks;
  final int plannedCompletionPercent;
}


