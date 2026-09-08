import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/analytics/analytics_service.dart';
import '../data/folder_repository.dart';
import 'task_controller.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository(
    ref.watch(appDatabaseProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
  );
});

final foldersProvider = FutureProvider<List<Folder>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.folders).get();
});


