import '../recurrence_type.dart';

class RecurrenceEngine {
  DateTime nextDate({
    required DateTime anchorDate,
    required RecurrenceType type,
    required DateTime after,
    int interval = 1,
  }) {
    final anchor = _dateOnly(anchorDate);
    final boundary = _dateOnly(after);
    final step = interval < 1 ? 1 : interval;
    return switch (type) {
      RecurrenceType.daily => _nextDaily(anchor, boundary, step),
      RecurrenceType.weekly => _nextWeekly(anchor, boundary, step),
      RecurrenceType.monthly => _nextMonthly(anchor, boundary, step),
    };
  }

  DateTime _nextDaily(DateTime anchor, DateTime boundary, int step) {
    var candidate = anchor;
    while (!candidate.isAfter(boundary)) {
      candidate = candidate.add(Duration(days: step));
    }
    return candidate;
  }

  DateTime _nextWeekly(DateTime anchor, DateTime boundary, int step) {
    var candidate = anchor;
    while (!candidate.isAfter(boundary)) {
      candidate = candidate.add(Duration(days: step * 7));
    }
    return candidate;
  }

  DateTime _nextMonthly(DateTime anchor, DateTime boundary, int step) {
    var monthOffset = step;
    while (true) {
      final candidate = _clampedMonthDate(anchor, monthOffset);
      if (candidate.isAfter(boundary)) {
        return candidate;
      }
      monthOffset += step;
    }
  }

  DateTime _clampedMonthDate(DateTime anchor, int monthOffset) {
    final target = DateTime(anchor.year, anchor.month + monthOffset);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    final day = anchor.day > lastDay ? lastDay : anchor.day;
    return DateTime(target.year, target.month, day);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}


