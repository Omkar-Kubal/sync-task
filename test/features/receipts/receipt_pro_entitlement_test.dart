import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synctasks/features/receipts/pro/receipt_pro_billing_service.dart';
import 'package:synctasks/features/receipts/pro/receipt_pro_entitlement.dart';
import 'package:synctasks/features/receipts/pro/receipt_pro_products.dart';

import 'fake_receipt_pro_billing_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('authoritative empty ownership starts free', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);

    final state = await harness.read();

    expect(state.status, ReceiptProEntitlementStatus.free);
    expect(state.isPro, isFalse);
    expect(harness.service.queryCount, 1);
  });

  test('purchased unlimited receipts persists before acknowledgment', () async {
    final operations = <String>[];
    final harness = _Harness(
      operations: operations,
      ownership: ReceiptProOwnershipSnapshot.fromEvents(const [
        ReceiptProPurchaseEvent(
          productId: syncTasksReceiptsUnlimitedProductId,
          state: ReceiptProPurchaseState.purchased,
          pendingCompletePurchaseOverride: true,
        ),
      ]),
    );
    addTearDown(harness.dispose);

    final state = await harness.read();

    expect(state.status, ReceiptProEntitlementStatus.pro);
    expect(operations, ['persist', 'complete']);
  });

  test(
    'pending ownership keeps receipts locked and clears stale cache',
    () async {
      final harness = _Harness(
        initiallyUnlocked: true,
        ownership: ReceiptProOwnershipSnapshot.fromEvents(const [
          ReceiptProPurchaseEvent(
            productId: syncTasksReceiptsUnlimitedProductId,
            state: ReceiptProPurchaseState.pending,
          ),
        ]),
      );
      addTearDown(harness.dispose);

      final state = await harness.read();

      expect(state.status, ReceiptProEntitlementStatus.pending);
      expect(state.isPro, isFalse);
      expect(harness.store.unlocked, isFalse);
    },
  );

  test(
    'authoritative empty ownership clears stale receipt pro cache',
    () async {
      final harness = _Harness(initiallyUnlocked: true);
      addTearDown(harness.dispose);

      final state = await harness.read();

      expect(state.status, ReceiptProEntitlementStatus.free);
      expect(harness.store.unlocked, isFalse);
    },
  );

  test('unavailable Play preserves cached unlimited receipts', () async {
    final harness = _Harness(initiallyUnlocked: true, available: false);
    addTearDown(harness.dispose);

    final state = await harness.read();

    expect(state.status, ReceiptProEntitlementStatus.pro);
    expect(state.isPro, isTrue);
    expect(harness.store.unlocked, isTrue);
    expect(harness.service.queryCount, 0);
  });

  test('stream purchase unlocks and completes pending purchase', () async {
    final operations = <String>[];
    final harness = _Harness(operations: operations);
    addTearDown(harness.dispose);
    await harness.read();
    operations.clear();

    harness.service.emit(
      const ReceiptProPurchaseEvent(
        productId: syncTasksReceiptsUnlimitedProductId,
        state: ReceiptProPurchaseState.purchased,
        pendingCompletePurchaseOverride: true,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = harness.container
        .read(receiptProEntitlementProvider)
        .requireValue;
    expect(state.isPro, isTrue);
    expect(operations, ['persist', 'complete']);
  });

  test(
    'restore with no ownership reports that no active purchase was found',
    () async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      await harness.read();

      await harness.container
          .read(receiptProEntitlementProvider.notifier)
          .restore();

      final state = harness.container
          .read(receiptProEntitlementProvider)
          .requireValue;
      expect(state.status, ReceiptProEntitlementStatus.free);
      expect(state.message, 'No active unlimited receipts purchase found.');
    },
  );

  test('clearTransientMessage clears free restore notice only', () async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await harness.read();

    final notifier = harness.container.read(
      receiptProEntitlementProvider.notifier,
    );
    await notifier.restore();

    notifier.clearTransientMessage();

    final state = harness.container
        .read(receiptProEntitlementProvider)
        .requireValue;
    expect(state.status, ReceiptProEntitlementStatus.free);
    expect(state.message, isNull);
  });
}

class _Harness {
  _Harness({
    bool initiallyUnlocked = false,
    bool available = true,
    ReceiptProOwnershipSnapshot? ownership,
    List<String>? operations,
  }) : store = _FakeReceiptProEntitlementStore(
         unlocked: initiallyUnlocked,
         operations: operations,
       ),
       service = FakeReceiptProBillingService(
         available: available,
         ownership: ownership,
         completeAction: (_) async => operations?.add('complete'),
       ) {
    container = ProviderContainer(
      overrides: [
        receiptProBillingServiceProvider.overrideWithValue(service),
        receiptProEntitlementStoreProvider.overrideWithValue(store),
      ],
    );
  }

  final _FakeReceiptProEntitlementStore store;
  final FakeReceiptProBillingService service;
  late final ProviderContainer container;

  Future<ReceiptProEntitlementState> read() =>
      container.read(receiptProEntitlementProvider.future);

  void dispose() {
    container.dispose();
    unawaited(service.close());
  }
}

class _FakeReceiptProEntitlementStore implements ReceiptProEntitlementStore {
  _FakeReceiptProEntitlementStore({required this.unlocked, this.operations});

  bool unlocked;
  final List<String>? operations;

  @override
  Future<bool> isUnlocked() async => unlocked;

  @override
  Future<void> saveUnlimitedReceiptsUnlock() async {
    operations?.add('persist');
    unlocked = true;
  }

  @override
  Future<void> clearUnlock() async {
    operations?.add('clear');
    unlocked = false;
  }
}
