import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/recurrence_type.dart';
import '../domain/services/recurrence_engine.dart';
import '../domain/task.dart' as domain;

class TaskRepository {
  TaskRepository(
    this._db, {
    DateTime Function()? now,
    RecurrenceEngine? recurrenceEngine,
  }) : _now = now ?? DateTime.now,
       _recurrenceEngine = recurrenceEngine ?? RecurrenceEngine();

  final AppDatabase _db;
  final DateTime Function() _now;
  final RecurrenceEngine _recurrenceEngine;

  Future<TaskSery?> getSeriesForTask(int seriesId) async {
    return (_db.select(
      _db.taskSeries,
    )..where((row) => row.id.equals(seriesId))).getSingleOrNull();
  }

  Future<Task?> getTask(int id) async {
    return (_db.select(
      _db.tasks,
    )..where((task) => task.id.equals(id))).getSingleOrNull();
  }

  Future<int> createTask(domain.TaskDraft draft) async {
    final folderId = draft.folderId ?? (await _inbox()).id;
    final createdAt = _now();
    final sortOrder = await _nextSortOrder();

    if (draft.recurrenceType == null) {
      return _db
          .into(_db.tasks)
          .insert(
            TasksCompanion.insert(
              folderId: folderId,
              title: draft.title,
              scheduledDate: Value(_dateOnlyOrNull(draft.scheduledDate)),
              scheduledTime: Value(draft.scheduledTime),
              reminderTime: Value(draft.reminderTime),
              focusDurationMinutes: Value(draft.focusDurationMinutes),
              globalSortOrder: sortOrder,
              createdAt: createdAt,
            ),
          );
    }

    if (draft.scheduledDate == null) {
      throw ArgumentError('Recurring tasks require a scheduled date.');
    }

    return _db.transaction(() async {
      final seriesId = await _db
          .into(_db.taskSeries)
          .insert(
            TaskSeriesCompanion.insert(
              title: draft.title,
              folderId: folderId,
              repeatType: draft.recurrenceType!.name,
              recurrenceInterval: Value(draft.recurrenceInterval ?? 1),
              customRepeatLabel: Value(draft.customRepeatLabel),
              anchorDate: _dateOnlyOrNull(draft.scheduledDate)!,
              time: Value(draft.scheduledTime),
              reminderTime: Value(draft.reminderTime),
              focusDurationMinutes: Value(draft.focusDurationMinutes),
              createdAt: createdAt,
            ),
          );
      return _insertOccurrence(
        seriesId: seriesId,
        folderId: folderId,
        title: draft.title,
        scheduledDate: _dateOnlyOrNull(draft.scheduledDate),
        scheduledTime: draft.scheduledTime,
        reminderTime: draft.reminderTime,
        focusDurationMinutes: draft.focusDurationMinutes,
        globalSortOrder: sortOrder,
        createdAt: createdAt,
      );
    });
  }

  Future<void> updateTaskTitle(int id, String title) async {
    await (_db.update(_db.tasks)..where((task) => task.id.equals(id))).write(
      TasksCompanion(title: Value(title)),
    );
  }

  Future<void> updateTask(int id, domain.TaskDraft draft) async {
    await _db.transaction(() async {
      final current = await _taskById(id);
      final folderId = draft.folderId ?? current.folderId;
      final scheduledDate = _dateOnlyOrNull(draft.scheduledDate);
      final recurrenceType = draft.recurrenceType;
      int? seriesId = current.seriesId;

      if (recurrenceType == null && current.seriesId != null) {
        await (_db.update(_db.taskSeries)
              ..where((series) => series.id.equals(current.seriesId!)))
            .write(const TaskSeriesCompanion(isActive: Value(false)));
        seriesId = null;
      } else if (recurrenceType != null) {
        if (scheduledDate == null) {
          throw ArgumentError('Recurring tasks require a scheduled date.');
        }
        if (current.seriesId == null) {
          seriesId = await _db
              .into(_db.taskSeries)
              .insert(
                TaskSeriesCompanion.insert(
                  title: draft.title,
                  folderId: folderId,
                  repeatType: recurrenceType.name,
                  recurrenceInterval: Value(draft.recurrenceInterval ?? 1),
                  customRepeatLabel: Value(draft.customRepeatLabel),
                  anchorDate: scheduledDate,
                  time: Value(draft.scheduledTime),
                  reminderTime: Value(draft.reminderTime),
                  focusDurationMinutes: Value(draft.focusDurationMinutes),
                  createdAt: _now(),
                ),
              );
        } else {
          await (_db.update(
            _db.taskSeries,
          )..where((series) => series.id.equals(current.seriesId!))).write(
            TaskSeriesCompanion(
              title: Value(draft.title),
              folderId: Value(folderId),
              repeatType: Value(recurrenceType.name),
              recurrenceInterval: Value(draft.recurrenceInterval ?? 1),
              customRepeatLabel: Value(draft.customRepeatLabel),
              anchorDate: Value(scheduledDate),
              time: Value(draft.scheduledTime),
              reminderTime: Value(draft.reminderTime),
              focusDurationMinutes: Value(draft.focusDurationMinutes),
              isActive: const Value(true),
            ),
          );
        }
      }

      await (_db.update(_db.tasks)..where((task) => task.id.equals(id))).write(
        TasksCompanion(
          seriesId: Value(seriesId),
          folderId: Value(folderId),
          title: Value(draft.title),
          scheduledDate: Value(scheduledDate),
          scheduledTime: Value(draft.scheduledTime),
          reminderTime: Value(draft.reminderTime),
          focusDurationMinutes: Value(draft.focusDurationMinutes),
        ),
      );
    });
  }

  Future<domain.TaskSnapshot> completeTask(int id) async {
    return _db.transaction(() async {
      final task = await _taskById(id);
      await (_db.update(_db.tasks)..where((row) => row.id.equals(id))).write(
        TasksCompanion(
          isCompleted: const Value(true),
          completedAt: Value(_now()),
        ),
      );

      final successorId = task.seriesId == null
          ? null
          : await _createNextOccurrence(task);
      return domain.TaskSnapshot(taskId: id, generatedSuccessorId: successorId);
    });
  }

  Future<domain.TaskSnapshot> deleteTask(int id) async {
    return _db.transaction(() async {
      final task = await _taskById(id);
      final successorId = task.seriesId == null
          ? null
          : await _createNextOccurrence(task);
      await (_db.delete(_db.tasks)..where((row) => row.id.equals(id))).go();
      return domain.TaskSnapshot(taskId: id, generatedSuccessorId: successorId);
    });
  }

  Future<void> rescheduleTasks(Iterable<int> ids, DateTime? scheduledDate) {
    final taskIds = ids.toSet();
    if (taskIds.isEmpty) {
      return Future.value();
    }
    return (_db.update(
      _db.tasks,
    )..where((task) => task.id.isIn(taskIds))).write(
      TasksCompanion(scheduledDate: Value(_dateOnlyOrNull(scheduledDate))),
    );
  }

  Future<void> moveTasksToFolder(Iterable<int> ids, int folderId) {
    final taskIds = ids.toSet();
    if (taskIds.isEmpty) {
      return Future.value();
    }
    return (_db.update(_db.tasks)..where((task) => task.id.isIn(taskIds)))
        .write(TasksCompanion(folderId: Value(folderId)));
  }

  Future<void> restoreTask(domain.TaskSnapshot snapshot) async {
    await _db.transaction(() async {
      if (snapshot.generatedSuccessorId != null) {
        await (_db.delete(_db.tasks)
              ..where((task) => task.id.equals(snapshot.generatedSuccessorId!)))
            .go();
      }
      await (_db.update(
        _db.tasks,
      )..where((task) => task.id.equals(snapshot.taskId))).write(
        const TasksCompanion(
          isCompleted: Value(false),
          completedAt: Value(null),
        ),
      );
    });
  }

  Future<List<Task>> listTodayTasks() async {
    final today = _dateOnly(_now());
    return (_activeTaskQuery()
          ..where((task) => task.scheduledDate.isSmallerOrEqualValue(today))
          ..orderBy(_taskOrdering))
        .get();
  }

  Future<List<Task>> listUpcomingTasks() async {
    final today = _dateOnly(_now());
    return (_activeTaskQuery()
          ..where((task) => task.scheduledDate.isBiggerOrEqualValue(today))
          ..orderBy(_taskOrdering))
        .get();
  }

  Future<List<Task>> listAllActiveTasks() async {
    return (_activeTaskQuery()..orderBy(_taskOrdering)).get();
  }

  Future<List<Task>> listCompletedTasks() async {
    return (_db.select(_db.tasks)
          ..where((task) => task.isCompleted.equals(true))
          ..orderBy(_taskOrdering))
        .get();
  }

  Future<List<Task>> listCompletedTasksForLocalDay(DateTime day) {
    final start = _dateOnly(day);
    final end = start.add(const Duration(days: 1));
    return listCompletedTasksInRange(start, end);
  }

  Future<List<Task>> listCompletedTasksInRange(
    DateTime startInclusive,
    DateTime endExclusive,
  ) {
    return (_db.select(_db.tasks)
          ..where(
            (task) =>
                task.isCompleted.equals(true) &
                task.completedAt.isBiggerOrEqualValue(startInclusive) &
                task.completedAt.isSmallerThanValue(endExclusive),
          )
          ..orderBy([
            (task) => OrderingTerm.asc(task.completedAt),
            (task) => OrderingTerm.asc(task.id),
          ]))
        .get();
  }

  Future<List<Task>> listReminderTasks() async {
    return (_activeTaskQuery()
          ..where((task) => task.reminderTime.isNotNull())
          ..orderBy(_taskOrdering))
        .get();
  }

  Future<List<Task>> listFolderTasks(int folderId) async {
    return (_activeTaskQuery()
          ..where((task) => task.folderId.equals(folderId))
          ..orderBy(_taskOrdering))
        .get();
  }

  Future<List<Task>> searchTasks(
    String query, {
    bool? isCompleted,
    DateTime? scheduledDate,
    DateTime? scheduledFrom,
    int? folderId,
  }) async {
    final statement = _db.select(_db.tasks)
      ..where((task) => task.title.contains(query));
    if (isCompleted != null) {
      statement.where((task) => task.isCompleted.equals(isCompleted));
    }
    if (scheduledDate != null) {
      statement.where(
        (task) => task.scheduledDate.equals(_dateOnly(scheduledDate)),
      );
    }
    if (scheduledFrom != null) {
      statement.where(
        (task) =>
            task.scheduledDate.isBiggerOrEqualValue(_dateOnly(scheduledFrom)),
      );
    }
    if (folderId != null) {
      statement.where((task) => task.folderId.equals(folderId));
    }
    return (statement..orderBy(_taskOrdering)).get();
  }

  SimpleSelectStatement<$TasksTable, Task> _activeTaskQuery() {
    return _db.select(_db.tasks)
      ..where((task) => task.isCompleted.equals(false));
  }

  List<OrderingTerm Function($TasksTable)> get _taskOrdering {
    return [
      (task) => OrderingTerm.asc(task.globalSortOrder),
      (task) => OrderingTerm.asc(task.createdAt),
      (task) => OrderingTerm.asc(task.id),
    ];
  }

  Future<int> _createNextOccurrence(Task task) async {
    final series = await (_db.select(
      _db.taskSeries,
    )..where((row) => row.id.equals(task.seriesId!))).getSingle();
    if (!series.isActive) {
      throw StateError('Cannot create occurrence for inactive series.');
    }

    final nextDate = _recurrenceEngine.nextDate(
      anchorDate: series.anchorDate,
      type: RecurrenceType.fromStorage(series.repeatType),
      after: _now(),
      interval: series.recurrenceInterval,
    );

    return _insertOccurrence(
      seriesId: series.id,
      folderId: series.folderId,
      title: series.title,
      scheduledDate: nextDate,
      scheduledTime: series.time,
      reminderTime: series.reminderTime,
      focusDurationMinutes: series.focusDurationMinutes,
      globalSortOrder: await _nextSortOrder(),
      createdAt: _now(),
    );
  }

  Future<int> _insertOccurrence({
    required int seriesId,
    required int folderId,
    required String title,
    required DateTime? scheduledDate,
    required DateTime? scheduledTime,
    required DateTime? reminderTime,
    required int? focusDurationMinutes,
    required int globalSortOrder,
    required DateTime createdAt,
  }) {
    return _db
        .into(_db.tasks)
        .insert(
          TasksCompanion.insert(
            seriesId: Value(seriesId),
            folderId: folderId,
            title: title,
            scheduledDate: Value(scheduledDate),
            scheduledTime: Value(scheduledTime),
            reminderTime: Value(reminderTime),
            focusDurationMinutes: Value(focusDurationMinutes),
            globalSortOrder: globalSortOrder,
            createdAt: createdAt,
          ),
        );
  }

  Future<Task> _taskById(int id) async {
    return (_db.select(
      _db.tasks,
    )..where((task) => task.id.equals(id))).getSingle();
  }

  Future<Folder> _inbox() async {
    return (_db.select(
      _db.folders,
    )..where((folder) => folder.name.equals('Inbox'))).getSingle();
  }

  Future<int> _nextSortOrder() async {
    final maxQuery = _db.selectOnly(_db.tasks)
      ..addColumns([_db.tasks.globalSortOrder.max()]);
    final row = await maxQuery.getSingleOrNull();
    final maxVal = row?.read(_db.tasks.globalSortOrder.max());
    return (maxVal ?? 0) + 1;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime? _dateOnlyOrNull(DateTime? value) =>
      value == null ? null : _dateOnly(value);
}
