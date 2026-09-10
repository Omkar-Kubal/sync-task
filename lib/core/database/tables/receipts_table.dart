import 'package:drift/drift.dart';

import 'tasks_table.dart';

class Receipts extends Table {
  TextColumn get id => text()();
  TextColumn get operationId => text().unique()();
  IntColumn get displayNumber => integer()();
  TextColumn get title => text()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get selectedStart => dateTime().nullable()();
  DateTimeColumn get selectedEndExclusive => dateTime().nullable()();
  BoolColumn get includeFolderLabels =>
      boolean().withDefault(const Constant(false))();
  TextColumn get artworkType => text().nullable()();
  TextColumn get drawingStrokesJson => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get templateVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ReceiptItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get receiptId => text().references(Receipts, #id)();
  IntColumn get taskId => integer().nullable().references(Tasks, #id)();
  IntColumn get position => integer()();
  TextColumn get titleSnapshot => text()();
  TextColumn get folderSnapshot => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
}

class ReceiptUsageEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationId => text().unique()();
  TextColumn get receiptId => text().references(Receipts, #id)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get weekStart => dateTime()();
  TextColumn get grantType => text().withDefault(const Constant('free'))();
}
