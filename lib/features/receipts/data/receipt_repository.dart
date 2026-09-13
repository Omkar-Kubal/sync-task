import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/receipt_composer_seed.dart';

const int freeReceiptsPerWeek = 3;

class ReceiptCreateRequest {
  const ReceiptCreateRequest({
    required this.operationId,
    required this.source,
    required this.defaultTitle,
    required this.title,
    required this.selectedTaskIds,
    this.periodStart,
    this.periodEndExclusive,
    this.includeFolderLabels = false,
    this.artworkType,
    this.drawingStrokesJson,
    this.photoPath,
    this.hasUnlimitedReceipts = false,
  });

  final String operationId;
  final ReceiptEntrySource source;
  final String defaultTitle;
  final String title;
  final List<int> selectedTaskIds;
  final DateTime? periodStart;
  final DateTime? periodEndExclusive;
  final bool includeFolderLabels;
  final String? artworkType;
  final String? drawingStrokesJson;
  final String? photoPath;
  final bool hasUnlimitedReceipts;
}

class SavedReceipt {
  const SavedReceipt({
    required this.id,
    required this.operationId,
    required this.displayNumber,
    required this.title,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.includeFolderLabels,
    required this.items,
    this.periodStart,
    this.periodEndExclusive,
    this.artworkType,
    this.drawingStrokesJson,
    this.photoPath,
  });

  final String id;
  final String operationId;
  final int displayNumber;
  final String title;
  final ReceiptEntrySource source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool includeFolderLabels;
  final DateTime? periodStart;
  final DateTime? periodEndExclusive;
  final List<SavedReceiptItem> items;
  final String? artworkType;
  final String? drawingStrokesJson;
  final String? photoPath;

  bool get hasDrawingArtwork =>
      artworkType == 'drawing' &&
      drawingStrokesJson != null &&
      drawingStrokesJson!.isNotEmpty;

  bool get hasPhotoArtwork =>
      artworkType == 'photo' && photoPath != null && photoPath!.isNotEmpty;
}

class SavedReceiptItem {
  const SavedReceiptItem({
    required this.taskId,
    required this.position,
    required this.title,
    required this.completedAt,
    this.folderName,
  });

  final int? taskId;
  final int position;
  final String title;
  final String? folderName;
  final DateTime completedAt;
}

class ReceiptListItem {
  const ReceiptListItem({
    required this.id,
    required this.displayNumber,
    required this.title,
    required this.createdAt,
    required this.taskCount,
  });

  final String id;
  final int displayNumber;
  final String title;
  final DateTime createdAt;
  final int taskCount;
}

class ReceiptQuotaStatus {
  const ReceiptQuotaStatus({
    required this.weekStart,
    required this.weekEndExclusive,
    required this.usedThisWeek,
    this.freeLimit = freeReceiptsPerWeek,
  });

  final DateTime weekStart;
  final DateTime weekEndExclusive;
  final int usedThisWeek;
  final int freeLimit;

  int get remainingThisWeek => max(0, freeLimit - usedThisWeek);
  bool get isExhausted => remainingThisWeek == 0;
}

class ReceiptQuotaExceededException implements Exception {
  const ReceiptQuotaExceededException(this.status);

  final ReceiptQuotaStatus status;
}

class ReceiptEmptySelectionException implements Exception {
  const ReceiptEmptySelectionException();
}

class ReceiptSelectionChangedException implements Exception {
  const ReceiptSelectionChangedException();
}

class ReceiptRepository {
  ReceiptRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<ReceiptQuotaStatus> quotaStatus() async {
    final now = _now();
    final weekStart = _localWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final events =
        await (_db.select(_db.receiptUsageEvents)..where(
              (event) =>
                  event.weekStart.equals(weekStart) &
                  event.grantType.equals('free'),
            ))
            .get();
    return ReceiptQuotaStatus(
      weekStart: weekStart,
      weekEndExclusive: weekEnd,
      usedThisWeek: events.length,
    );
  }

  Future<List<ReceiptListItem>> listReceipts() async {
    final receipts =
        await (_db.select(_db.receipts)..orderBy([
              (receipt) => OrderingTerm.desc(receipt.createdAt),
              (receipt) => OrderingTerm.desc(receipt.displayNumber),
            ]))
            .get();
    final result = <ReceiptListItem>[];
    for (final receipt in receipts) {
      final items = await (_db.select(
        _db.receiptItems,
      )..where((item) => item.receiptId.equals(receipt.id))).get();
      result.add(
        ReceiptListItem(
          id: receipt.id,
          displayNumber: receipt.displayNumber,
          title: receipt.title,
          createdAt: receipt.createdAt,
          taskCount: items.length,
        ),
      );
    }
    return result;
  }

  Future<SavedReceipt?> getReceipt(String id) async {
    final receipt = await (_db.select(
      _db.receipts,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (receipt == null) {
      return null;
    }
    return _receiptFromRow(receipt);
  }

  Future<SavedReceipt> generateReceipt(ReceiptCreateRequest request) async {
    final selectedIds = request.selectedTaskIds.toSet().toList();
    if (selectedIds.isEmpty) {
      throw const ReceiptEmptySelectionException();
    }

    return _db.transaction(() async {
      final existing = await _receiptByOperationId(request.operationId);
      if (existing != null) {
        return existing;
      }

      final now = _now();
      final quota = await quotaStatus();
      if (quota.isExhausted && !request.hasUnlimitedReceipts) {
        throw ReceiptQuotaExceededException(quota);
      }

      final snapshots = await _completedSnapshots(selectedIds);
      if (snapshots.length != selectedIds.length) {
        throw const ReceiptSelectionChangedException();
      }

      final displayNumber = await _nextDisplayNumber();
      final receiptId = _newReceiptId(now);
      await _db
          .into(_db.receipts)
          .insert(
            ReceiptsCompanion.insert(
              id: receiptId,
              operationId: request.operationId,
              displayNumber: displayNumber,
              title: _resolvedTitle(request.title, request.defaultTitle),
              source: request.source.name,
              createdAt: now,
              updatedAt: now,
              selectedStart: Value(request.periodStart),
              selectedEndExclusive: Value(request.periodEndExclusive),
              includeFolderLabels: Value(request.includeFolderLabels),
              artworkType: Value(request.artworkType),
              drawingStrokesJson: Value(request.drawingStrokesJson),
              photoPath: Value(request.photoPath),
            ),
          );

      for (var i = 0; i < snapshots.length; i++) {
        final snapshot = snapshots[i];
        await _db
            .into(_db.receiptItems)
            .insert(
              ReceiptItemsCompanion.insert(
                receiptId: receiptId,
                taskId: Value(snapshot.taskId),
                position: i,
                titleSnapshot: snapshot.title,
                folderSnapshot: Value(
                  request.includeFolderLabels ? snapshot.folderName : null,
                ),
                completedAt: snapshot.completedAt,
              ),
            );
      }

      await _db
          .into(_db.receiptUsageEvents)
          .insert(
            ReceiptUsageEventsCompanion.insert(
              operationId: request.operationId,
              receiptId: receiptId,
              createdAt: now,
              weekStart: quota.weekStart,
              grantType: Value(request.hasUnlimitedReceipts ? 'pro' : 'free'),
            ),
          );

      return (await getReceipt(receiptId))!;
    });
  }

  Future<SavedReceipt?> _receiptByOperationId(String operationId) async {
    final receipt = await (_db.select(
      _db.receipts,
    )..where((row) => row.operationId.equals(operationId))).getSingleOrNull();
    if (receipt == null) {
      return null;
    }
    return _receiptFromRow(receipt);
  }

  Future<SavedReceipt> _receiptFromRow(Receipt receipt) async {
    final items =
        await (_db.select(_db.receiptItems)
              ..where((item) => item.receiptId.equals(receipt.id))
              ..orderBy([(item) => OrderingTerm.asc(item.position)]))
            .get();
    return SavedReceipt(
      id: receipt.id,
      operationId: receipt.operationId,
      displayNumber: receipt.displayNumber,
      title: receipt.title,
      source: ReceiptEntrySource.values.byName(receipt.source),
      createdAt: receipt.createdAt,
      updatedAt: receipt.updatedAt,
      includeFolderLabels: receipt.includeFolderLabels,
      periodStart: receipt.selectedStart,
      periodEndExclusive: receipt.selectedEndExclusive,
      artworkType: receipt.artworkType,
      drawingStrokesJson: receipt.drawingStrokesJson,
      photoPath: receipt.photoPath,
      items: [
        for (final item in items)
          SavedReceiptItem(
            taskId: item.taskId,
            position: item.position,
            title: item.titleSnapshot,
            folderName: item.folderSnapshot,
            completedAt: item.completedAt,
          ),
      ],
    );
  }

  Future<int> _nextDisplayNumber() async {
    final receipts = await _db.select(_db.receipts).get();
    if (receipts.isEmpty) {
      return 1;
    }
    return receipts
            .map((receipt) => receipt.displayNumber)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  Future<List<_TaskSnapshotForReceipt>> _completedSnapshots(
    List<int> taskIds,
  ) async {
    final query = _db.select(_db.tasks).join([
      innerJoin(_db.folders, _db.folders.id.equalsExp(_db.tasks.folderId)),
    ])..where(_db.tasks.id.isIn(taskIds));
    final rows = await query.get();
    final snapshots = <_TaskSnapshotForReceipt>[];
    for (final row in rows) {
      final task = row.readTable(_db.tasks);
      if (!task.isCompleted || task.completedAt == null) {
        continue;
      }
      final folder = row.readTable(_db.folders);
      snapshots.add(
        _TaskSnapshotForReceipt(
          taskId: task.id,
          title: task.title,
          folderName: folder.name,
          completedAt: task.completedAt!,
        ),
      );
    }
    snapshots.sort((a, b) {
      final completedCompare = a.completedAt.compareTo(b.completedAt);
      if (completedCompare != 0) {
        return completedCompare;
      }
      return a.taskId.compareTo(b.taskId);
    });
    return snapshots;
  }

  String _newReceiptId(DateTime now) =>
      'receipt-${now.microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

  String _resolvedTitle(String title, String defaultTitle) {
    final trimmed = title.trim();
    final resolved = trimmed.isEmpty ? defaultTitle.trim() : trimmed;
    if (resolved.length <= 80) {
      return resolved;
    }
    return resolved.substring(0, 80);
  }

  DateTime _localWeekStart(DateTime value) {
    final localDay = DateTime(value.year, value.month, value.day);
    return localDay.subtract(Duration(days: localDay.weekday - 1));
  }
}

class _TaskSnapshotForReceipt {
  const _TaskSnapshotForReceipt({
    required this.taskId,
    required this.title,
    required this.folderName,
    required this.completedAt,
  });

  final int taskId;
  final String title;
  final String folderName;
  final DateTime completedAt;
}
