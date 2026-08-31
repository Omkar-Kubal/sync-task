import '../../../core/database/app_database.dart';
import '../domain/activity_day.dart';
import '../domain/insights_summary.dart';

class InsightsRepository {
  InsightsRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<InsightsSummary> summary() async {
    final today = _dateOnly(_now());
    final weekStart = today.subtract(Duration(days: today.weekday - DateTime.monday));
    final tomorrow = today.add(const Duration(days: 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final focusRows = await _db.select(_db.focusHistory).get();
    final tasks = await _db.select(_db.tasks).get();

    final todayRuns = focusRows.where((run) => _isInRange(run.completedAt, today, tomorrow)).toList();
    final weekRuns = focusRows.where((run) => _isInRange(run.completedAt, weekStart, weekEnd)).toList();
    final completedToday = tasks.where((task) {
      final completedAt = task.completedAt;
      return completedAt != null && _isInRange(completedAt, today, tomorrow);
    }).length;

    return InsightsSummary(
      todayFocusRuns: todayRuns.length,
      weekFocusRuns: weekRuns.length,
      todayFocusedDuration: Duration(
        minutes: todayRuns.fold<int>(0, (sum, run) => sum + run.actualDurationMinutes),
      ),
      weekFocusedDuration: Duration(
        minutes: weekRuns.fold<int>(0, (sum, run) => sum + run.actualDurationMinutes),
      ),
      todayCompletedTasks: completedToday,
      currentStreak: _currentStreak(focusRows.map((run) => _dateOnly(run.completedAt)).toSet(), today),
    );
  }

  Future<List<ActivityDay>> yearActivity(int year) async {
    final rows = await _db.select(_db.focusHistory).get();
    final counts = <DateTime, int>{};
    for (final row in rows) {
      final date = _dateOnly(row.completedAt);
      if (date.year == year) {
        counts[date] = (counts[date] ?? 0) + 1;
      }
    }

    final first = DateTime(year);
    final last = DateTime(year + 1);
    final days = <ActivityDay>[];
    for (var date = first; date.isBefore(last); date = date.add(const Duration(days: 1))) {
      final count = counts[date] ?? 0;
      days.add(ActivityDay(
        date: date,
        completedFocusRunCount: count,
        intensity: count >= 4 ? 4 : count,
      ));
    }
    return days;
  }

  int _currentStreak(Set<DateTime> focusDays, DateTime today) {
    var streak = 0;
    var cursor = today;
    while (focusDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool _isInRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
}
