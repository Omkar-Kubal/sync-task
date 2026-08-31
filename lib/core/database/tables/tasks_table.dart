import 'package:drift/drift.dart';

import 'folders_table.dart';
import 'task_series_table.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get seriesId => integer().nullable().references(TaskSeries, #id)();
  IntColumn get folderId => integer().references(Folders, #id)();
  TextColumn get title => text()();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get scheduledTime => dateTime().nullable()();
  DateTimeColumn get reminderTime => dateTime().nullable()();
  IntColumn get focusDurationMinutes => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get globalSortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
}
