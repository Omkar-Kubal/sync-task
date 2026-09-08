import '../../../core/database/app_database.dart';
import '../domain/activity_day.dart';
import '../domain/insights_summary.dart';

class InsightsRepository {
  InsightsRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<InsightsSummary> summary() async {
    final today = _dateOnly(_now());
    final weekStart = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    final tomorrow = today.add(const Duration(days: 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final tasks = await _db.select(_db.tasks).get();

    final completedToday = tasks.where((task) {
      final completedAt = task.completedAt;
      return completedAt != null && _isInRange(completedAt, today, tomorrow);
    }).length;
    final completedThisWeek = tasks.where((task) {
      final completedAt = task.completedAt;
      return completedAt != null && _isInRange(completedAt, weekStart, weekEnd);
    }).length;
    final completionDays = tasks
        .map((task) => task.completedAt)
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet();
    final completedLast28Days = tasks.where((task) {
      final completedAt = task.completedAt;
      return completedAt != null &&
          _isInRange(
            completedAt,
            today.subtract(const Duration(days: 27)),
            tomorrow,
          );
    }).toList();

    return InsightsSummary(
      todayCompletedTasks: completedToday,
      weekCompletedTasks: completedThisWeek,
      currentStreak: _currentStreak(completionDays, today),
      previousStreak: _currentStreak(
        completionDays,
        today.subtract(const Duration(days: 1)),
      ),
      completionTrend: _completionTrend(tasks, today),
      bestCompletionWeekdayLabel: _bestCompletionWeekdayLabel(
        completedLast28Days,
      ),
      bestCompletionWeekdayCount: _bestCompletionWeekdayCount(
        completedLast28Days,
      ),
      plannedCompletedTasks: completedLast28Days
          .where((task) => task.scheduledDate != null)
          .length,
      unplannedCompletedTasks: completedLast28Days
          .where((task) => task.scheduledDate == null)
          .length,
      plannedCompletionPercent: _plannedCompletionPercent(completedLast28Days),
    );
  }

  Future<List<ActivityDay>> yearActivity(int year) async {
    final rows = await _db.select(_db.tasks).get();
    final counts = <DateTime, int>{};
    for (final row in rows) {
      final completedAt = row.completedAt;
      if (completedAt == null) {
        continue;
      }
      final date = _dateOnly(completedAt);
      if (date.year == year) {
        counts[date] = (counts[date] ?? 0) + 1;
      }
    }

    final first = DateTime(year);
    final last = DateTime(year + 1);
    final days = <ActivityDay>[];
    for (
      var date = first;
      date.isBefore(last);
      date = date.add(const Duration(days: 1))
    ) {
      final count = counts[date] ?? 0;
      days.add(
        ActivityDay(
          date: date,
          completedTaskCount: count,
          intensity: count >= 4 ? 4 : count,
        ),
      );
    }
    return days;
  }

  int _currentStreak(Set<DateTime> completedDays, DateTime today) {
    var streak = 0;
    var cursor = today;
    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<CompletionTrendPoint> _completionTrend(
    List<Task> tasks,
    DateTime today,
  ) {
    final counts = <DateTime, int>{};
    for (final task in tasks) {
      final completedAt = task.completedAt;
      if (completedAt == null) {
        continue;
      }
      final date = _dateOnly(completedAt);
      counts[date] = (counts[date] ?? 0) + 1;
    }
    return [
      for (var offset = 6; offset >= 0; offset--)
        CompletionTrendPoint(
          date: today.subtract(Duration(days: offset)),
          completedTaskCount:
              counts[today.subtract(Duration(days: offset))] ?? 0,
        ),
    ];
  }

  String _bestCompletionWeekdayLabel(List<Task> tasks) {
    final weekday = _bestCompletionWeekday(tasks);
    if (weekday == null) {
      return 'No completion pattern yet';
    }
    return _weekdayLabels[weekday - 1];
  }

  int _bestCompletionWeekdayCount(List<Task> tasks) {
    final weekday = _bestCompletionWeekday(tasks);
    if (weekday == null) {
      return 0;
    }
    return tasks.where((task) => task.completedAt!.weekday == weekday).length;
  }

  int? _bestCompletionWeekday(List<Task> tasks) {
    if (tasks.isEmpty) {
      return null;
    }
    final counts = <int, int>{};
    for (final task in tasks) {
      final weekday = task.completedAt!.weekday;
      counts[weekday] = (counts[weekday] ?? 0) + 1;
    }
    int? bestWeekday;
    var bestCount = 0;
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final count = counts[weekday] ?? 0;
      if (count > bestCount) {
        bestWeekday = weekday;
        bestCount = count;
      }
    }
    return bestWeekday;
  }

  int _plannedCompletionPercent(List<Task> tasks) {
    if (tasks.isEmpty) {
      return 0;
    }
    final planned = tasks.where((task) => task.scheduledDate != null).length;
    return (planned / tasks.length * 100).round();
  }

  bool _isInRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

const _weekdayLabels = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];


