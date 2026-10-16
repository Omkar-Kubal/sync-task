import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/features/tasks/domain/task_due_status.dart';

void main() {
  group('taskDueStatus', () {
    final now = DateTime(2026, 10, 8, 10, 30, 45);
    final today = DateTime(2026, 10, 8);

    TaskDueStatus status({
      bool isCompleted = false,
      required DateTime? date,
      DateTime? time,
    }) => taskDueStatus(
      isCompleted: isCompleted,
      scheduledDate: date,
      scheduledTime: time,
      now: now,
    );

    test('a task scheduled this minute is due today through that minute', () {
      expect(
        status(date: today, time: DateTime(2026, 1, 1, 10, 30)),
        TaskDueStatus.today,
      );
    });

    test('a task becomes overdue at the next minute boundary', () {
      expect(
        status(date: today, time: DateTime(2026, 1, 1, 10, 29)),
        TaskDueStatus.overdue,
      );
    });

    test('date-only tasks remain due today', () {
      expect(status(date: today), TaskDueStatus.today);
    });

    test('older tasks are overdue and future tasks are upcoming', () {
      expect(status(date: DateTime(2026, 10, 7)), TaskDueStatus.overdue);
      expect(status(date: DateTime(2026, 10, 9)), TaskDueStatus.upcoming);
    });

    test('completion takes precedence over overdue date and time', () {
      expect(
        status(
          isCompleted: true,
          date: DateTime(2026, 10, 7),
          time: DateTime(2026, 1, 1, 9),
        ),
        TaskDueStatus.completed,
      );
    });

    test('tasks without a date are unscheduled', () {
      expect(status(date: null), TaskDueStatus.unscheduled);
    });
  });
}
