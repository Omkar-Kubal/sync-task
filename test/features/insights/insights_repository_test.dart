import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/insights/data/insights_repository.dart';

void main() {
  late AppDatabase db;
  late InsightsRepository repository;

  setUp(() {
    db = AppDatabase.memory();
    repository = InsightsRepository(db, now: () => DateTime(2026, 9, 1, 12));
  });

  tearDown(() => db.close());

  test('summarizes completed tasks and streak', () async {
    final inbox = (await db.select(db.folders).get()).single;
    var sortOrder = 1;
    for (final day in [
      DateTime(2026, 8, 30),
      DateTime(2026, 8, 31),
      DateTime(2026, 9, 1),
      DateTime(2026, 9, 1, 10),
    ]) {
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              folderId: inbox.id,
              title: 'Done task $sortOrder',
              isCompleted: const Value(true),
              completedAt: Value(day),
              globalSortOrder: sortOrder++,
              createdAt: day.subtract(const Duration(hours: 1)),
            ),
          );
    }

    final summary = await repository.summary();
    expect(summary.todayCompletedTasks, 2);
    expect(summary.weekCompletedTasks, 3);
    expect(summary.currentStreak, 3);
  });

  test(
    'computes production task insights from completion and scheduling data',
    () async {
      final inbox = (await db.select(db.folders).get()).single;
      var sortOrder = 1;

      Future<void> insertDone({
        required String title,
        required DateTime completedAt,
        DateTime? scheduledDate,
      }) {
        return db
            .into(db.tasks)
            .insert(
              TasksCompanion.insert(
                folderId: inbox.id,
                title: title,
                scheduledDate: Value(scheduledDate),
                isCompleted: const Value(true),
                completedAt: Value(completedAt),
                globalSortOrder: sortOrder++,
                createdAt: completedAt.subtract(const Duration(hours: 1)),
              ),
            );
      }

      await insertDone(
        title: 'Tuesday one',
        completedAt: DateTime(2026, 9, 1, 9),
        scheduledDate: DateTime(2026, 9, 1),
      );
      await insertDone(
        title: 'Friday one',
        completedAt: DateTime(2026, 8, 28, 9),
        scheduledDate: DateTime(2026, 8, 28),
      );
      await insertDone(
        title: 'Friday two',
        completedAt: DateTime(2026, 8, 28, 10),
      );
      await insertDone(
        title: 'Monday one',
        completedAt: DateTime(2026, 8, 24, 9),
        scheduledDate: DateTime(2026, 8, 24),
      );

      final summary = await repository.summary();

      expect(summary.completionTrend, hasLength(7));
      expect(summary.completionTrend.first.date, DateTime(2026, 8, 26));
      expect(summary.completionTrend.last.date, DateTime(2026, 9, 1));
      expect(summary.completionTrend.last.completedTaskCount, 1);
      expect(summary.bestCompletionWeekdayLabel, 'Friday');
      expect(summary.bestCompletionWeekdayCount, 2);
      expect(summary.plannedCompletedTasks, 3);
      expect(summary.unplannedCompletedTasks, 1);
      expect(summary.plannedCompletionPercent, 75);
    },
  );

  test('reports recovery streak when today has no completed tasks', () async {
    final repository = InsightsRepository(
      db,
      now: () => DateTime(2026, 9, 4, 12),
    );
    final inbox = (await db.select(db.folders).get()).single;

    for (final day in [DateTime(2026, 9, 2), DateTime(2026, 9, 3)]) {
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              folderId: inbox.id,
              title: 'Recovered',
              isCompleted: const Value(true),
              completedAt: Value(day),
              globalSortOrder: day.day,
              createdAt: day,
            ),
          );
    }

    final summary = await repository.summary();

    expect(summary.currentStreak, 0);
    expect(summary.previousStreak, 2);
  });
}


