import 'package:drift/drift.dart';

import 'tasks_table.dart';

class FocusHistory extends Table {
  @override
  String get tableName => 'focus_history';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get plannedDurationMinutes => integer()();
  IntColumn get actualDurationMinutes => integer()();
  BoolColumn get wasExtended => boolean()();
  DateTimeColumn get createdAt => dateTime()();
}
