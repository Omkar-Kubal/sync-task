import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/focus_history_table.dart';
import 'tables/folders_table.dart';
import 'tables/task_series_table.dart';
import 'tables/tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Folders, TaskSeries, Tasks, FocusHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        await _ensureInboxFolder();
      },
    );
  }

  Future<void> _ensureInboxFolder() async {
    final existing = await (select(folders)..where((folder) => folder.name.equals('Inbox'))).get();
    if (existing.isNotEmpty) {
      return;
    }

    await into(folders).insert(
      FoldersCompanion.insert(
        name: 'Inbox',
        sortOrder: 0,
        createdAt: DateTime.now(),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'synctask.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
