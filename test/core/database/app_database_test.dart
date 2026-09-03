import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  test('database starts at explicit schema version one', () {
    expect(db.schemaVersion, 1);
  });

  test('database starts with permanent Inbox folder', () async {
    final folders = await db.select(db.folders).get();

    expect(folders, hasLength(1));
    expect(folders.single.name, 'Inbox');
    expect(folders.single.sortOrder, 0);
  });

  test(
    'database inserts minimal task and completed focus history rows',
    () async {
      final now = DateTime(2026, 8, 31, 10);
      final folder = (await db.select(db.folders).get()).single;
      final taskId = await db
          .into(db.tasks)
          .insert(
            TasksCompanion.insert(
              folderId: folder.id,
              title: 'Write report',
              globalSortOrder: 1,
              createdAt: now,
            ),
          );

      await db
          .into(db.focusHistory)
          .insert(
            FocusHistoryCompanion.insert(
              taskId: Value(taskId),
              startedAt: now,
              completedAt: now.add(const Duration(minutes: 45)),
              plannedDurationMinutes: 45,
              actualDurationMinutes: 45,
              wasExtended: false,
              createdAt: now.add(const Duration(minutes: 45)),
            ),
          );

      expect(await db.select(db.tasks).get(), hasLength(1));
      expect(await db.select(db.focusHistory).get(), hasLength(1));
    },
  );
}
