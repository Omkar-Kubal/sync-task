import 'package:drift/drift.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/database/app_database.dart';

class FolderRepository {
  factory FolderRepository(
    AppDatabase db, {
    DateTime Function()? now,
    AnalyticsService? analyticsService,
  }) {
    return FolderRepository._(db, now ?? DateTime.now, analyticsService);
  }

  FolderRepository._(this._db, this._now, this._analyticsService);

  final AppDatabase _db;
  final DateTime Function() _now;
  final AnalyticsService? _analyticsService;

  Future<Folder> inbox() async {
    return (_db.select(
      _db.folders,
    )..where((folder) => folder.name.equals('Inbox'))).getSingle();
  }

  Future<Folder> createFolder(String name) async {
    final maxOrder = await _maxSortOrder();
    final folder = await _db
        .into(_db.folders)
        .insertReturning(
          FoldersCompanion.insert(
            name: name,
            sortOrder: maxOrder + 1,
            createdAt: _now(),
          ),
        );
    await _analyticsService?.logEvent(
      'folder_created',
      parameters: {'is_inbox': folder.name == 'Inbox'},
    );
    return folder;
  }

  Future<void> deleteFolder(int folderId) async {
    final inboxFolder = await inbox();
    if (folderId == inboxFolder.id) {
      return;
    }

    await _db.transaction(() async {
      await (_db.update(_db.tasks)
            ..where((task) => task.folderId.equals(folderId)))
          .write(TasksCompanion(folderId: Value(inboxFolder.id)));
      await (_db.delete(
        _db.folders,
      )..where((folder) => folder.id.equals(folderId))).go();
    });
  }

  Future<int> _maxSortOrder() async {
    final rows = await _db.select(_db.folders).get();
    if (rows.isEmpty) {
      return -1;
    }
    return rows
        .map((folder) => folder.sortOrder)
        .reduce((a, b) => a > b ? a : b);
  }
}


