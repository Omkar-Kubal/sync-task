import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';

void main() {
  test('database starts at explicit schema version five', () {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    expect(db.schemaVersion, 5);
  });

  test('receipts table includes photo artwork path', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    final columns = await db.customSelect('PRAGMA table_info(receipts)').get();
    final columnNames = {for (final row in columns) row.read<String>('name')};

    expect(columnNames, contains('photo_path'));
  });

  test('database starts with permanent Inbox folder', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    final folders = await db.select(db.folders).get();

    expect(folders, hasLength(1));
    expect(folders.single.name, 'Inbox');
    expect(folders.single.sortOrder, 0);
  });

  test(
    'database inserts minimal task and completed focus history rows',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);

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

  test(
    'schema four migration tolerates receipt artwork columns already present',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'synctasks_migration_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/synctasks.sqlite');

      final seeded = AppDatabase.connect(NativeDatabase(file));
      await seeded.select(seeded.folders).get();
      await seeded.customStatement('PRAGMA user_version = 3');
      await seeded.close();

      final migrated = AppDatabase.connect(NativeDatabase(file));
      addTearDown(migrated.close);

      final folder = (await migrated.select(migrated.folders).get()).single;
      final taskId = await migrated
          .into(migrated.tasks)
          .insert(
            TasksCompanion.insert(
              folderId: folder.id,
              title: 'Create after migration',
              globalSortOrder: 1,
              createdAt: DateTime(2026, 9, 10, 17),
            ),
          );

      expect(taskId, greaterThan(0));
    },
  );
}
