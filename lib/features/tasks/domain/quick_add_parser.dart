import 'quick_add_parse_result.dart';

QuickAddParseResult parseQuickAdd(String input, {DateTime? now}) {
  final baseDate = _dateOnly(now ?? DateTime.now());
  final rawTitle = _collapseWhitespace(input.trim());

  final noDate = _extract(
    rawTitle,
    RegExp(r'\bno\s+date\b', caseSensitive: false),
  );
  if (noDate != null) {
    return QuickAddParseResult(title: noDate, hasDateInstruction: true);
  }

  final nextWeek = _extract(
    rawTitle,
    RegExp(r'\bnext\s+week\b', caseSensitive: false),
  );
  if (nextWeek != null) {
    return QuickAddParseResult(
      title: nextWeek,
      scheduledDate: baseDate.add(const Duration(days: 7)),
      hasDateInstruction: true,
    );
  }

  final tomorrow = _extract(
    rawTitle,
    RegExp(r'\btomorrow\b', caseSensitive: false),
  );
  if (tomorrow != null) {
    return QuickAddParseResult(
      title: tomorrow,
      scheduledDate: baseDate.add(const Duration(days: 1)),
      hasDateInstruction: true,
    );
  }

  final today = _extract(rawTitle, RegExp(r'\btoday\b', caseSensitive: false));
  if (today != null) {
    return QuickAddParseResult(
      title: today,
      scheduledDate: baseDate,
      hasDateInstruction: true,
    );
  }

  for (final weekday in _weekdays.entries) {
    final match = _extract(
      rawTitle,
      RegExp('\\b${weekday.key}\\b', caseSensitive: false),
    );
    if (match != null) {
      return QuickAddParseResult(
        title: match,
        scheduledDate: baseDate.add(
          Duration(days: _daysUntilWeekday(baseDate.weekday, weekday.value)),
        ),
        hasDateInstruction: true,
      );
    }
  }

  return QuickAddParseResult(title: rawTitle);
}

const _weekdays = <String, int>{
  'monday': DateTime.monday,
  'tuesday': DateTime.tuesday,
  'wednesday': DateTime.wednesday,
  'thursday': DateTime.thursday,
  'friday': DateTime.friday,
  'saturday': DateTime.saturday,
  'sunday': DateTime.sunday,
};

String? _extract(String input, RegExp pattern) {
  if (!pattern.hasMatch(input)) {
    return null;
  }
  return _collapseWhitespace(input.replaceAll(pattern, '').trim());
}

String _collapseWhitespace(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ');
}

int _daysUntilWeekday(int currentWeekday, int targetWeekday) {
  final days = (targetWeekday - currentWeekday) % DateTime.daysPerWeek;
  return days == 0 ? DateTime.daysPerWeek : days;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}


