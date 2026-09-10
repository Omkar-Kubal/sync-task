import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final receiptFeatureEnabledProvider = Provider<bool>((ref) {
  return const bool.fromEnvironment('SYNCTASKS_RECEIPTS_PHASE1') ||
      !kReleaseMode;
});
