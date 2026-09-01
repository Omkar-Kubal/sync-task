import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/database/app_database.dart';
import 'package:synctask/features/insights/data/insights_repository.dart';

void main() {
  test('activity grid intensity is based on completed focus run count', () async {
    final db = AppDatabase.memory();
    final repository = InsightsRepository(db, now: () => DateTime(2026, 9, 1, 12));
    final date = DateTime(2026, 9, 1);

    for (var i = 0; i < 4; i++) {
      await db.into(db.focusHistory).insert(
            FocusHistoryCompanion.insert(
              startedAt: date.add(Duration(hours: i)),
              completedAt: date.add(Duration(hours: i, minutes: 20)),
              plannedDurationMinutes: 20,
              actualDurationMinutes: 20,
              wasExtended: false,
              createdAt: date.add(Duration(hours: i, minutes: 20)),
            ),
          );
    }

    final grid = await repository.yearActivity(2026);
    final activeDay = grid.singleWhere((day) => day.date == date);

    expect(activeDay.completedFocusRunCount, 4);
    expect(activeDay.intensity, 4);
    await db.close();
  });
}
