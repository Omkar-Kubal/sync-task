import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/sync_sounds.dart';

final receiptPrintingFeedbackProvider = Provider<ReceiptPrintingFeedback>(
  (ref) => const SystemReceiptPrintingFeedback(),
);

abstract class ReceiptPrintingFeedback {
  const ReceiptPrintingFeedback();

  ReceiptPrintingFeedbackHandle start();
}

abstract class ReceiptPrintingFeedbackHandle {
  void stop();
}

class SystemReceiptPrintingFeedback implements ReceiptPrintingFeedback {
  const SystemReceiptPrintingFeedback();

  @override
  ReceiptPrintingFeedbackHandle start() {
    final handle = _SystemReceiptPrintingFeedbackHandle();
    handle.start();
    return handle;
  }
}

class _SystemReceiptPrintingFeedbackHandle
    implements ReceiptPrintingFeedbackHandle {
  static const _tick = Duration(milliseconds: 230);
  SyncSoundLoopHandle? _soundHandle;
  Timer? _timer;
  var _ticks = 0;

  void start() {
    _soundHandle = SyncSounds.startLoop(SyncSoundLoop.receiptPrinting);
    _emit();
    _timer = Timer.periodic(_tick, (_) => _emit());
  }

  void _emit() {
    _ticks++;
    if (_ticks.isOdd) {
      unawaited(HapticFeedback.selectionClick());
    }
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    _soundHandle?.stop();
    _soundHandle = null;
  }
}
