import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final receiptPhotoCaptureServiceProvider = Provider<ReceiptPhotoCaptureService>(
  (ref) => const MethodChannelReceiptPhotoCaptureService(),
);

abstract class ReceiptPhotoCaptureService {
  const ReceiptPhotoCaptureService();

  Future<String?> capturePhoto();
}

class MethodChannelReceiptPhotoCaptureService
    implements ReceiptPhotoCaptureService {
  const MethodChannelReceiptPhotoCaptureService();

  static const MethodChannel _channel = MethodChannel(
    'com.appylab.synctasks/receipts/photo',
  );

  @override
  Future<String?> capturePhoto() {
    return _channel.invokeMethod<String>('capturePhoto');
  }
}
