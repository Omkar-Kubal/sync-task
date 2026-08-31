import '../recurrence_type.dart';

class RecurrenceEngine {
  DateTime nextDate({
    required DateTime anchorDate,
    required RecurrenceType type,
    required DateTime after,
  }) {
    final anchor = _dateOnly(anchorDate);
    final boundary = _dateOnly(after);
    return switch (type) {
      RecurrenceType.daily => _nextDaily(anchor, boundary),
      RecurrenceType.weekly => _nextWeekly(anchor, boundary),
      RecurrenceType.monthly => _nextMonthly(anchor, boundary),
    };
  }

  DateTime _nextDaily(DateTime anchor, DateTime boundary) {
    var candidate = anchor;
    while (!candidate.isAfter(boundary)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  DateTime _nextWeekly(DateTime anchor, DateTime boundary) {
    var candidate = anchor;
    while (!candidate.isAfter(boundary)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }

  DateTime _nextMonthly(DateTime anchor, DateTime boundary) {
    var monthOffset = 1;
    while (true) {
      final candidate = _clampedMonthDate(anchor, monthOffset);
      if (candidate.isAfter(boundary)) {
        return candidate;
      }
      monthOffset++;
    }
  }

  DateTime _clampedMonthDate(DateTime anchor, int monthOffset) {
    final target = DateTime(anchor.year, anchor.month + monthOffset);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    final day = anchor.day > lastDay ? lastDay : anchor.day;
    return DateTime(target.year, target.month, day);
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
}
