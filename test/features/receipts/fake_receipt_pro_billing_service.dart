import 'dart:async';

import 'package:synctasks/features/receipts/pro/receipt_pro_billing_service.dart';
import 'package:synctasks/features/receipts/pro/receipt_pro_products.dart';

ReceiptProOwnershipSnapshot fakeOwnedReceiptProSnapshot() {
  return ReceiptProOwnershipSnapshot.fromEvents(const [
    ReceiptProPurchaseEvent(
      productId: syncTasksReceiptsUnlimitedProductId,
      state: ReceiptProPurchaseState.purchased,
    ),
  ]);
}

class FakeReceiptProBillingService implements ReceiptProBillingService {
  FakeReceiptProBillingService({
    this.available = true,
    this.autoPurchaseOnBuy = false,
    ReceiptProOwnershipSnapshot? ownership,
    this.ownershipQuery,
    this.catalog,
    this.buyAction,
    this.completeAction,
  }) : ownership =
           ownership ??
           ReceiptProOwnershipSnapshot.fromEvents(
             const <ReceiptProPurchaseEvent>[],
           );

  final bool available;
  final bool autoPurchaseOnBuy;
  final ReceiptProOwnershipSnapshot ownership;
  final Future<ReceiptProOwnershipSnapshot> Function()? ownershipQuery;
  final ReceiptProCatalog? catalog;
  final Future<void> Function()? buyAction;
  final Future<void> Function(ReceiptProPurchaseEvent event)? completeAction;
  final _controller =
      StreamController<List<ReceiptProPurchaseEvent>>.broadcast();

  int buyCount = 0;
  int queryCount = 0;
  int completeCount = 0;

  @override
  Stream<List<ReceiptProPurchaseEvent>> get purchaseUpdates =>
      _controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ReceiptProCatalog> loadCatalog() async {
    return catalog ??
        ReceiptProCatalog.fromProductPrices(const {
          syncTasksReceiptsUnlimitedProductId: '₹199',
        });
  }

  @override
  Future<void> buyUnlimitedReceipts() async {
    buyCount++;
    if (buyAction != null) {
      await buyAction!();
      return;
    }
    if (autoPurchaseOnBuy) {
      emitPurchased();
    }
  }

  @override
  Future<ReceiptProOwnershipSnapshot> queryOwnership() async {
    queryCount++;
    return ownershipQuery?.call() ?? ownership;
  }

  @override
  Future<void> completePurchase(ReceiptProPurchaseEvent event) async {
    completeCount++;
    await completeAction?.call(event);
  }

  void emitPurchased() {
    emit(
      const ReceiptProPurchaseEvent(
        productId: syncTasksReceiptsUnlimitedProductId,
        state: ReceiptProPurchaseState.purchased,
      ),
    );
  }

  void emit(ReceiptProPurchaseEvent event) {
    _controller.add([event]);
  }

  void emitError() {
    _controller.addError(StateError('purchase stream failed'));
  }

  Future<void> close() => _controller.close();
}
