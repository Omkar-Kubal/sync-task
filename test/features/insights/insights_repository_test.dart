import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/database/app_database.dart';
import 'package:synctask/features/insights/data/insights_repository.dart';

void main() {
  late AppDatabase db;
  late InsightsRepository repository;

  setUp(() {
    db = AppDatabase.memory();
    repository = InsightsRepository(db, now: () => DateTime(2026, 9, 1, 12));
  });

  tearDown(() => db.close());

  test('summarizes focus history tasks completed and streak', () async {
    final inbox = (await db.select(db.folders).get()).single;
    await db.into(db.tasks).insert(
          TasksCompanion.insert(
            folderId: inbox.id,
            title: 'Done task',
            isCompleted: const Value(true),
            completedAt: Value(DateTime(2026, 9, 1, 8)),
            globalSortOrder: 1,
            createdAt: DateTime(2026, 9, 1, 7),
          ),
        );
    for (final day in [DateTime(2026, 8, 31), DateTime(2026, 9, 1)]) {
      await db.into(db.focusHistory).insert(
            FocusHistoryCompanion.insert(
              startedAt: day.add(const Duration(hours: 9)),
              completedAt: day.add(const Duration(hours: 9, minutes: 30)),
              plannedDurationMinutes: 30,
              actualDurationMinutes: 30,
              wasExtended: false,
              createdAt: day.add(const Duration(hours: 9, minutes: 30)),
            ),
          );
    }
    await db.into(db.focusHistory).insert(
          FocusHistoryCompanion.insert(
            startedAt: DateTime(2026, 8, 30, 9),
            completedAt: DateTime(2026, 8, 30, 9, 30),
            plannedDurationMinutes: 30,
            actualDurationMinutes: 30,
            wasExtended: false,
            createdAt: DateTime(2026, 8, 30, 9, 30),
          ),
        );
    await db.into(db.focusHistory).insert(
          FocusHistoryCompanion.insert(
            startedAt: DateTime(2026, 9, 1, 10),
            completedAt: DateTime(2026, 9, 1, 10, 30),
            plannedDurationMinutes: 30,
            actualDurationMinutes: 30,
            wasExtended: false,
            createdAt: DateTime(2026, 9, 1, 10, 30),
          ),
        );

    final summary = await repository.summary();
    expect(summary.todayFocusRuns, 2);
    expect(summary.weekFocusRuns, 3);
    expect(summary.todayFocusedDuration, const Duration(minutes: 60));
    expect(summary.weekFocusedDuration, const Duration(minutes: 90));
    expect(summary.todayCompletedTasks, 1);
    expect(summary.currentStreak, 3);
  });
}
