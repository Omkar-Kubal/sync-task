import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SyncHaptics {
  const SyncHaptics._();

  static const _minimumFeedbackGap = Duration(milliseconds: 90);

  static bool enabled = true;
  static bool mildHaptics = true;
  static DateTime? _lastFeedbackAt;

  static void selection() {
    _emitSoftFeedback();
  }

  static void action() {
    _emitSoftFeedback();
  }

  static void complete() {
    _emitSoftFeedback();
  }

  static void destructive() {
    _emitSoftFeedback();
  }

  static void _emitSoftFeedback() {
    if (!enabled) return;
    final now = DateTime.now();
    final lastFeedbackAt = _lastFeedbackAt;
    if (lastFeedbackAt != null &&
        now.difference(lastFeedbackAt) < _minimumFeedbackGap) {
      return;
    }
    _lastFeedbackAt = now;
    unawaited(HapticFeedback.selectionClick());
  }

  @visibleForTesting
  static void resetForTesting() {
    enabled = true;
    mildHaptics = true;
    _lastFeedbackAt = null;
  }
}


