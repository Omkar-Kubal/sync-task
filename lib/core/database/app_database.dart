import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/focus_history_table.dart';
import 'tables/folders_table.dart';
import 'tables/receipts_table.dart';
import 'tables/task_series_table.dart';
import 'tables/tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Folders,
    TaskSeries,
    Tasks,
    FocusHistory,
    Receipts,
    ReceiptItems,
    ReceiptUsageEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _createReceiptIndexes();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(taskSeries, taskSeries.recurrenceInterval);
          await m.addColumn(taskSeries, taskSeries.customRepeatLabel);
        }
        if (from < 3) {
          await m.createTable(receipts);
          await m.createTable(receiptItems);
          await m.createTable(receiptUsageEvents);
          await _createReceiptIndexes();
        }
        if (from < 4) {
          await m.addColumn(receipts, receipts.artworkType);
          await m.addColumn(receipts, receipts.drawingStrokesJson);
        }
      },
      beforeOpen: (details) async {
        await _createReceiptIndexes();
        await _ensureInboxFolder();
      },
    );
  }

  Future<void> _createReceiptIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_receipts_created_at '
      'ON receipts(created_at DESC, display_number DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_receipt_items_receipt_id '
      'ON receipt_items(receipt_id, position)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_receipt_usage_events_week_grant '
      'ON receipt_usage_events(week_start, grant_type)',
    );
  }

  Future<void> _ensureInboxFolder() async {
    final existing = await (select(
      folders,
    )..where((folder) => folder.name.equals('Inbox'))).get();
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
    final file = File(p.join(directory.path, 'synctasks.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
