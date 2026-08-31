import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class FolderRepository {
  FolderRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<Folder> inbox() async {
    return (_db.select(_db.folders)..where((folder) => folder.name.equals('Inbox'))).getSingle();
  }

  Future<Folder> createFolder(String name) async {
    final maxOrder = await _maxSortOrder();
    return _db.into(_db.folders).insertReturning(
          FoldersCompanion.insert(
            name: name,
            sortOrder: maxOrder + 1,
            createdAt: _now(),
          ),
        );
  }

  Future<void> deleteFolder(int folderId) async {
    final inboxFolder = await inbox();
    if (folderId == inboxFolder.id) {
      return;
    }

    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((task) => task.folderId.equals(folderId))).write(
        TasksCompanion(folderId: Value(inboxFolder.id)),
      );
      await (_db.delete(_db.folders)..where((folder) => folder.id.equals(folderId))).go();
    });
  }

  Future<int> _maxSortOrder() async {
    final rows = await _db.select(_db.folders).get();
    if (rows.isEmpty) {
      return -1;
    }
    return rows.map((folder) => folder.sortOrder).reduce((a, b) => a > b ? a : b);
  }
}
