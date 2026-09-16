enum ReceiptProPlanId { unlimitedReceipts }

const syncTasksReceiptsUnlimitedProductId =
    'synctasks_receipts_unlimited_lifetime';

class ReceiptProPlan {
  const ReceiptProPlan({
    required this.id,
    required this.productId,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.available,
    this.unavailableReason,
  });

  final ReceiptProPlanId id;
  final String productId;
  final String title;
  final String subtitle;
  final String? price;
  final bool available;
  final String? unavailableReason;

  ReceiptProPlan copyWith({
    String? price,
    bool? available,
    String? unavailableReason,
  }) {
    return ReceiptProPlan(
      id: id,
      productId: productId,
      title: title,
      subtitle: subtitle,
      price: price ?? this.price,
      available: available ?? this.available,
      unavailableReason: unavailableReason ?? this.unavailableReason,
    );
  }
}

ReceiptProPlan fallbackUnlimitedReceiptsPlan({
  bool available = false,
  String? unavailableReason,
}) {
  return ReceiptProPlan(
    id: ReceiptProPlanId.unlimitedReceipts,
    productId: syncTasksReceiptsUnlimitedProductId,
    title: 'Unlimited receipts',
    subtitle: 'One-time purchase',
    price: null,
    available: available,
    unavailableReason: unavailableReason,
  );
}
