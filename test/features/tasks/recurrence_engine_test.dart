import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/features/tasks/domain/recurrence_type.dart';
import 'package:sync_task/features/tasks/domain/services/recurrence_engine.dart';

void main() {
  final engine = RecurrenceEngine();

  test('daily recurrence does not backfill missed days', () {
    final next = engine.nextDate(
      anchorDate: DateTime(2026, 8, 31),
      type: RecurrenceType.daily,
      after: DateTime(2026, 9, 2, 10),
    );

    expect(next, DateTime(2026, 9, 3));
  });

  test('weekly recurrence preserves original weekday cadence', () {
    final next = engine.nextDate(
      anchorDate: DateTime(2026, 8, 31),
      type: RecurrenceType.weekly,
      after: DateTime(2026, 9, 2),
    );

    expect(next, DateTime(2026, 9, 7));
  });

  test('monthly recurrence uses last day when anchor day is unavailable', () {
    final next = engine.nextDate(
      anchorDate: DateTime(2026, 1, 31),
      type: RecurrenceType.monthly,
      after: DateTime(2026, 1, 31, 12),
    );

    expect(next, DateTime(2026, 2, 28));
  });
}
