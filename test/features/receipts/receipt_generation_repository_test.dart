import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/receipts/data/receipt_repository.dart';
import 'package:synctasks/features/receipts/domain/receipt_composer_seed.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  test('database starts at schema version five with receipt indexes', () async {
    expect(db.schemaVersion, 5);
    expect(db.receipts.actualTableName, 'receipts');
    expect(db.receiptItems.actualTableName, 'receipt_items');
    expect(db.receiptUsageEvents.actualTableName, 'receipt_usage_events');
    final indexRows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name LIKE 'idx_receipt%'",
        )
        .get();
    final indexNames = {for (final row in indexRows) row.read<String>('name')};
    expect(
      indexNames,
      containsAll({
        'idx_receipts_created_at',
        'idx_receipt_items_receipt_id',
        'idx_receipt_usage_events_week_grant',
      }),
    );
  });

  test(
    'generation snapshots completed tasks and consumes one weekly slot',
    () async {
      final tasks = TaskRepository(db);
      final taskId = await tasks.createTask(
        const domain.TaskDraft(title: 'Ship Phase 2A'),
      );
      await TaskRepository(
        db,
        now: () => DateTime(2026, 9, 9, 18),
      ).completeTask(taskId);

      final receipts = ReceiptRepository(
        db,
        now: () => DateTime(2026, 9, 10, 9),
      );

      final receipt = await receipts.generateReceipt(
        ReceiptCreateRequest(
          operationId: 'op-one',
          source: ReceiptEntrySource.today,
          defaultTitle: "Today's wins",
          title: '  Launch wins  ',
          selectedTaskIds: [taskId],
          includeFolderLabels: true,
        ),
      );

      expect(receipt.displayNumber, 1);
      expect(receipt.title, 'Launch wins');
      expect(receipt.items, hasLength(1));
      expect(receipt.items.single.title, 'Ship Phase 2A');
      expect(receipt.items.single.folderName, 'Inbox');
      expect(receipt.items.single.completedAt, DateTime(2026, 9, 9, 18));

      final quota = await receipts.quotaStatus();
      expect(quota.usedThisWeek, 1);
      expect(quota.remainingThisWeek, 2);
    },
  );

  test(
    'saved receipt keeps task snapshots after source task is restored',
    () async {
      final tasks = TaskRepository(db);
      final taskId = await tasks.createTask(
        const domain.TaskDraft(title: 'Snapshot me'),
      );
      final snapshot = await TaskRepository(
        db,
        now: () => DateTime(2026, 9, 9, 12),
      ).completeTask(taskId);

      final receipts = ReceiptRepository(
        db,
        now: () => DateTime(2026, 9, 10, 9),
      );
      final receipt = await receipts.generateReceipt(
        ReceiptCreateRequest(
          operationId: 'op-snapshot',
          source: ReceiptEntrySource.completedSelection,
          defaultTitle: 'Completed tasks',
          title: 'Completed tasks',
          selectedTaskIds: [taskId],
        ),
      );

      await tasks.restoreTask(snapshot);

      final saved = await receipts.getReceipt(receipt.id);
      expect(saved, isNotNull);
      expect(saved!.items.single.title, 'Snapshot me');
      expect(saved.items.single.completedAt, DateTime(2026, 9, 9, 12));
    },
  );

  test('generation persists photo artwork path', () async {
    final tasks = TaskRepository(db);
    final taskId = await tasks.createTask(
      const domain.TaskDraft(title: 'Photo proof'),
    );
    await TaskRepository(
      db,
      now: () => DateTime(2026, 9, 9, 12),
    ).completeTask(taskId);

    final receipts = ReceiptRepository(db, now: () => DateTime(2026, 9, 10, 9));
    final receipt = await receipts.generateReceipt(
      ReceiptCreateRequest(
        operationId: 'op-photo',
        source: ReceiptEntrySource.completedSelection,
        defaultTitle: 'Completed tasks',
        title: 'Photo wins',
        selectedTaskIds: [taskId],
        artworkType: 'photo',
        photoPath: 'D:\\temp\\receipt-photo.jpg',
      ),
    );

    expect(receipt.hasPhotoArtwork, isTrue);
    expect(receipt.photoPath, 'D:\\temp\\receipt-photo.jpg');
    expect(receipt.hasDrawingArtwork, isFalse);

    final saved = await receipts.getReceipt(receipt.id);
    expect(saved!.hasPhotoArtwork, isTrue);
    expect(saved.photoPath, 'D:\\temp\\receipt-photo.jpg');
  });

  test(
    'duplicate operation id returns existing receipt without double charge',
    () async {
      final tasks = TaskRepository(db);
      final taskId = await tasks.createTask(
        const domain.TaskDraft(title: 'Once'),
      );
      await TaskRepository(
        db,
        now: () => DateTime(2026, 9, 9, 12),
      ).completeTask(taskId);
      final receipts = ReceiptRepository(
        db,
        now: () => DateTime(2026, 9, 10, 9),
      );
      final request = ReceiptCreateRequest(
        operationId: 'op-idempotent',
        source: ReceiptEntrySource.today,
        defaultTitle: "Today's wins",
        title: "Today's wins",
        selectedTaskIds: [taskId],
      );

      final first = await receipts.generateReceipt(request);
      final second = await receipts.generateReceipt(request);

      expect(second.id, first.id);
      expect(await receipts.listReceipts(), hasLength(1));
      expect((await receipts.quotaStatus()).usedThisWeek, 1);
    },
  );

  test(
    'fourth free receipt in one week is blocked without consuming a slot',
    () async {
      final tasks = TaskRepository(db);
      final taskIds = <int>[];
      for (var i = 0; i < 4; i++) {
        final id = await tasks.createTask(domain.TaskDraft(title: 'Task $i'));
        await TaskRepository(
          db,
          now: () => DateTime(2026, 9, 9, 8 + i),
        ).completeTask(id);
        taskIds.add(id);
      }
      final receipts = ReceiptRepository(
        db,
        now: () => DateTime(2026, 9, 10, 9),
      );

      for (var i = 0; i < 3; i++) {
        await receipts.generateReceipt(
          ReceiptCreateRequest(
            operationId: 'op-$i',
            source: ReceiptEntrySource.completedSelection,
            defaultTitle: 'Completed tasks',
            title: 'Completed tasks',
            selectedTaskIds: [taskIds[i]],
          ),
        );
      }

      await expectLater(
        receipts.generateReceipt(
          ReceiptCreateRequest(
            operationId: 'op-four',
            source: ReceiptEntrySource.completedSelection,
            defaultTitle: 'Completed tasks',
            title: 'Fourth receipt',
            selectedTaskIds: [taskIds.last],
          ),
        ),
        throwsA(isA<ReceiptQuotaExceededException>()),
      );

      expect(await receipts.listReceipts(), hasLength(3));
      final quota = await receipts.quotaStatus();
      expect(quota.usedThisWeek, 3);
      expect(quota.remainingThisWeek, 0);
    },
  );
}
