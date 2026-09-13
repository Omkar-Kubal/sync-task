import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/features/receipts/pro/receipt_pro_billing_service.dart';
import 'package:synctasks/features/receipts/pro/receipt_pro_products.dart';

void main() {
  test('catalog has no price when receipts product is missing', () {
    final catalog = ReceiptProCatalog.fromProductPrices(const {});

    expect(catalog.unlimitedReceipts.price, isNull);
    expect(catalog.unlimitedReceipts.available, isFalse);
    expect(
      catalog.unlimitedReceipts.unavailableReason,
      'Unlimited receipts are not available yet.',
    );
  });

  test(
    'catalog uses localized Play price when receipts product is available',
    () {
      final catalog = ReceiptProCatalog.fromProductPrices(const {
        syncTasksReceiptsUnlimitedProductId: '₹199.00',
      });

      expect(catalog.unlimitedReceipts.price, '₹199.00');
      expect(catalog.unlimitedReceipts.available, isTrue);
    },
  );

  test('owned receipt purchase is authoritative', () {
    final snapshot = ReceiptProOwnershipSnapshot.fromEvents(const [
      ReceiptProPurchaseEvent(
        productId: syncTasksReceiptsUnlimitedProductId,
        state: ReceiptProPurchaseState.purchased,
      ),
    ]);

    expect(snapshot.ownsUnlimitedReceipts, isTrue);
    expect(snapshot.pendingUnlimitedReceipts, isFalse);
    expect(snapshot.isAuthoritative, isTrue);
  });

  test('pending receipt purchase never unlocks unlimited receipts', () {
    final snapshot = ReceiptProOwnershipSnapshot.fromEvents(const [
      ReceiptProPurchaseEvent(
        productId: syncTasksReceiptsUnlimitedProductId,
        state: ReceiptProPurchaseState.pending,
      ),
    ]);

    expect(snapshot.ownsUnlimitedReceipts, isFalse);
    expect(snapshot.pendingUnlimitedReceipts, isTrue);
  });
}
