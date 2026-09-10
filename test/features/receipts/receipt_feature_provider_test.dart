import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/features/receipts/providers/receipt_feature_provider.dart';

void main() {
  test('receipt feature is visible by default outside release builds', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(receiptFeatureEnabledProvider), !kReleaseMode);
  });
}
