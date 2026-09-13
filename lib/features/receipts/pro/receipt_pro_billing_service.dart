import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'receipt_pro_products.dart';

enum ReceiptProPurchaseState { purchased, restored, pending, canceled, error }

class ReceiptProPurchaseEvent {
  const ReceiptProPurchaseEvent({
    required this.productId,
    required this.state,
    this.errorMessage,
    this.pendingCompletePurchaseOverride,
    this.rawPurchase,
  });

  final String productId;
  final ReceiptProPurchaseState state;
  final String? errorMessage;
  final bool? pendingCompletePurchaseOverride;
  final PurchaseDetails? rawPurchase;

  bool get pendingCompletePurchase =>
      pendingCompletePurchaseOverride ??
      rawPurchase?.pendingCompletePurchase ??
      false;
}

class ReceiptProOwnershipSnapshot {
  ReceiptProOwnershipSnapshot({
    required this.ownsUnlimitedReceipts,
    required this.pendingUnlimitedReceipts,
    required List<ReceiptProPurchaseEvent> events,
    this.queryError,
  }) : events = List.unmodifiable(events);

  factory ReceiptProOwnershipSnapshot.fromEvents(
    List<ReceiptProPurchaseEvent> events, {
    String? queryError,
  }) {
    final receiptEvents = events.where(
      (event) => event.productId == syncTasksReceiptsUnlimitedProductId,
    );
    return ReceiptProOwnershipSnapshot(
      ownsUnlimitedReceipts: receiptEvents.any(
        (event) =>
            event.state == ReceiptProPurchaseState.purchased ||
            event.state == ReceiptProPurchaseState.restored,
      ),
      pendingUnlimitedReceipts: receiptEvents.any(
        (event) => event.state == ReceiptProPurchaseState.pending,
      ),
      events: events,
      queryError: queryError,
    );
  }

  final bool ownsUnlimitedReceipts;
  final bool pendingUnlimitedReceipts;
  final List<ReceiptProPurchaseEvent> events;
  final String? queryError;

  bool get isAuthoritative => queryError == null;
}

class ReceiptProCatalog {
  const ReceiptProCatalog({required this.unlimitedReceipts, this.errorMessage});

  final ReceiptProPlan unlimitedReceipts;
  final String? errorMessage;

  factory ReceiptProCatalog.fromProductPrices(
    Map<String, String> prices, {
    String? errorMessage,
  }) {
    final price = prices[syncTasksReceiptsUnlimitedProductId];
    return ReceiptProCatalog(
      unlimitedReceipts: fallbackUnlimitedReceiptsPlan(
        available: price != null,
        unavailableReason: price == null
            ? 'Unlimited receipts are not available yet.'
            : null,
      ).copyWith(price: price),
      errorMessage: errorMessage,
    );
  }

  factory ReceiptProCatalog.fromProductDetails(
    List<ProductDetails> products, {
    String? errorMessage,
  }) {
    return ReceiptProCatalog.fromProductPrices({
      for (final product in products)
        if (product.id == syncTasksReceiptsUnlimitedProductId)
          product.id: product.price,
    }, errorMessage: errorMessage);
  }

  factory ReceiptProCatalog.unavailable(String message) {
    return ReceiptProCatalog(
      unlimitedReceipts: fallbackUnlimitedReceiptsPlan(
        unavailableReason: message,
      ),
      errorMessage: message,
    );
  }
}

abstract class ReceiptProBillingService {
  Stream<List<ReceiptProPurchaseEvent>> get purchaseUpdates;
  Future<bool> isAvailable();
  Future<ReceiptProCatalog> loadCatalog();
  Future<void> buyUnlimitedReceipts();
  Future<ReceiptProOwnershipSnapshot> queryOwnership();
  Future<void> completePurchase(ReceiptProPurchaseEvent event);
}

typedef ReceiptProQueryPastPurchases =
    Future<QueryPurchaseDetailsResponse> Function();
typedef ReceiptProBuyNonConsumable =
    Future<bool> Function(PurchaseParam purchaseParam);

class InAppPurchaseReceiptProBillingService
    implements ReceiptProBillingService {
  InAppPurchaseReceiptProBillingService({
    this.inAppPurchase,
    this.queryPastPurchases,
    this.buyNonConsumable,
    this.productForTesting,
  });

  final InAppPurchase? inAppPurchase;
  final ReceiptProQueryPastPurchases? queryPastPurchases;
  final ReceiptProBuyNonConsumable? buyNonConsumable;
  ProductDetails? productForTesting;

  InAppPurchase get _billing => inAppPurchase ?? InAppPurchase.instance;

  @override
  Stream<List<ReceiptProPurchaseEvent>> get purchaseUpdates => _billing
      .purchaseStream
      .map((purchases) => purchases.map(_mapPurchase).toList());

  @override
  Future<bool> isAvailable() => _billing.isAvailable();

  @override
  Future<ReceiptProCatalog> loadCatalog() async {
    final response = await _billing.queryProductDetails(const {
      syncTasksReceiptsUnlimitedProductId,
    });
    for (final product in response.productDetails) {
      if (product.id == syncTasksReceiptsUnlimitedProductId) {
        productForTesting = product;
        break;
      }
    }

    if (response.error != null) {
      return ReceiptProCatalog.fromProductDetails(
        response.productDetails,
        errorMessage: response.error!.message,
      );
    }
    return ReceiptProCatalog.fromProductDetails(response.productDetails);
  }

  @override
  Future<void> buyUnlimitedReceipts() async {
    final product = productForTesting;
    if (product == null) {
      throw StateError('Unlimited receipts are not available yet.');
    }
    final launched =
        await (buyNonConsumable?.call(PurchaseParam(productDetails: product)) ??
            _billing.buyNonConsumable(
              purchaseParam: PurchaseParam(productDetails: product),
            ));
    if (!launched) {
      throw StateError('Google Play did not start the purchase.');
    }
  }

  @override
  Future<ReceiptProOwnershipSnapshot> queryOwnership() async {
    try {
      final response =
          await (queryPastPurchases?.call() ??
              _billing
                  .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
                  .queryPastPurchases());
      return ReceiptProOwnershipSnapshot.fromEvents(
        response.pastPurchases.map(_mapPurchase).toList(),
        queryError: response.error?.message,
      );
    } catch (_) {
      return ReceiptProOwnershipSnapshot.fromEvents(
        const [],
        queryError: 'Unable to verify purchases with Google Play.',
      );
    }
  }

  @override
  Future<void> completePurchase(ReceiptProPurchaseEvent event) async {
    final purchase = event.rawPurchase;
    if (purchase == null || !purchase.pendingCompletePurchase) return;
    await _billing.completePurchase(purchase);
  }

  static ReceiptProPurchaseEvent _mapPurchase(PurchaseDetails purchase) {
    return ReceiptProPurchaseEvent(
      productId: purchase.productID,
      state: switch (purchase.status) {
        PurchaseStatus.purchased => ReceiptProPurchaseState.purchased,
        PurchaseStatus.restored => ReceiptProPurchaseState.restored,
        PurchaseStatus.pending => ReceiptProPurchaseState.pending,
        PurchaseStatus.canceled => ReceiptProPurchaseState.canceled,
        PurchaseStatus.error => ReceiptProPurchaseState.error,
      },
      errorMessage: purchase.error?.message,
      rawPurchase: purchase,
    );
  }
}
