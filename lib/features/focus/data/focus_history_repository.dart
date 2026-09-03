import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/focus_run.dart';

class FocusHistoryRepository {
  const FocusHistoryRepository(this._db);

  final AppDatabase _db;

  Future<int> insertCompletedRun(FocusRun run) {
    return _db
        .into(_db.focusHistory)
        .insert(
          FocusHistoryCompanion.insert(
            taskId: Value(run.taskId),
            startedAt: run.startedAt,
            completedAt: run.completedAt,
            plannedDurationMinutes: run.plannedDuration.inMinutes,
            actualDurationMinutes: run.actualDuration.inMinutes,
            wasExtended: run.wasExtended,
            createdAt: run.completedAt,
          ),
        );
  }

  Future<List<FocusHistoryData>> all() {
    return _db.select(_db.focusHistory).get();
  }
}
