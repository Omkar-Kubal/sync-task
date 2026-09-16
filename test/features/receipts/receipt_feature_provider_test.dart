import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/features/receipts/providers/receipt_feature_provider.dart';

void main() {
  test('receipt feature follows the production feature flag default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(receiptFeatureEnabledProvider),
      const bool.fromEnvironment(
        'SYNCTASKS_RECEIPTS_PHASE1',
        defaultValue: true,
      ),
    );
  });
}
