import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/insights/data/insights_repository.dart';

void main() {
  test('activity grid intensity is based on completed task count', () async {
    final db = AppDatabase.memory();
    final repository = InsightsRepository(
      db,
      now: () => DateTime(2026, 9, 1, 12),
    );
    final date = DateTime(2026, 9, 1);

    for (var i = 0; i < 4; i++) {
      await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              folderId: (await db.select(db.folders).get()).single.id,
              title: 'Done $i',
              isCompleted: const Value(true),
              completedAt: Value(date.add(Duration(hours: i))),
              globalSortOrder: i,
              createdAt: date.add(Duration(hours: i - 1)),
            ),
          );
    }

    final grid = await repository.yearActivity(2026);
    final activeDay = grid.singleWhere((day) => day.date == date);

    expect(activeDay.completedTaskCount, 4);
    expect(activeDay.intensity, 4);
    await db.close();
  });
}


