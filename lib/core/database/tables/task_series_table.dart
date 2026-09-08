import 'package:drift/drift.dart';

import 'folders_table.dart';

class TaskSeries extends Table {
  @override
  String get tableName => 'task_series';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get folderId => integer().references(Folders, #id)();
  TextColumn get repeatType => text()();
  IntColumn get recurrenceInterval =>
      integer().withDefault(const Constant(1))();
  TextColumn get customRepeatLabel => text().nullable()();
  DateTimeColumn get anchorDate => dateTime()();
  DateTimeColumn get time => dateTime().nullable()();
  DateTimeColumn get reminderTime => dateTime().nullable()();
  IntColumn get focusDurationMinutes => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}


