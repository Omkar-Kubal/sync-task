import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/features/receipts/services/receipt_photo_processor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'processes captured photos into a black and white pixelite image',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('receipt-photo-');
      addTearDown(() => tempDir.delete(recursive: true));
      final sourceFile = File(
        '${tempDir.path}${Platform.pathSeparator}source.png',
      );
      await sourceFile.writeAsBytes(await _sourcePng());

      final outputPath = await const HalftoneReceiptPhotoProcessor()
          .processPhoto(sourceFile.path);

      expect(outputPath, isNot(sourceFile.path));
      expect(outputPath, endsWith('_pixelite.png'));
      final outputFile = File(outputPath);
      expect(outputFile.existsSync(), isTrue);

      final image = await _decodeImage(await outputFile.readAsBytes());
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      addTearDown(image.dispose);
      expect(rgba, isNotNull);
      expect(image.width, lessThanOrEqualTo(400));

      var darkLeft = 0;
      var darkRight = 0;
      var nonMonochromeSamples = 0;
      var centerRowTransitions = 0;
      bool? wasDark;
      final bytes = rgba!;
      for (var y = 0; y < image.height; y += 4) {
        for (var x = 0; x < image.width; x += 4) {
          final offset = (y * image.width + x) * 4;
          final red = bytes.getUint8(offset);
          final green = bytes.getUint8(offset + 1);
          final blue = bytes.getUint8(offset + 2);
          if ((red - green).abs() > 2 || (red - blue).abs() > 2) {
            nonMonochromeSamples++;
          }
          if (red < 96 && green < 96 && blue < 96) {
            if (x < image.width / 2) {
              darkLeft++;
            } else {
              darkRight++;
            }
          }
        }
      }
      final centerY = image.height ~/ 2;
      for (var x = 0; x < image.width / 2; x++) {
        final offset = (centerY * image.width + x) * 4;
        final isDark = bytes.getUint8(offset) < 96;
        if (wasDark != null && wasDark != isDark) {
          centerRowTransitions++;
        }
        wasDark = isDark;
      }

      expect(nonMonochromeSamples, 0);
      expect(darkLeft, greaterThan(darkRight * 3));
      expect(centerRowTransitions, greaterThanOrEqualTo(50));
      expect(centerRowTransitions, lessThanOrEqualTo(70));
    },
  );

  test('keeps a finer halftone grid for receipt photos', () async {
    final tempDir = await Directory.systemTemp.createTemp('receipt-photo-');
    addTearDown(() => tempDir.delete(recursive: true));
    final sourceFile = File(
      '${tempDir.path}${Platform.pathSeparator}source.png',
    );
    await sourceFile.writeAsBytes(await _sourcePng());

    final outputPath = await const HalftoneReceiptPhotoProcessor()
        .processPhoto(sourceFile.path);

    final image = await _decodeImage(await File(outputPath).readAsBytes());
    addTearDown(image.dispose);
    final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    expect(rgba, isNotNull);

    final bytes = rgba!;
    var darkColumns = 0;
    for (var x = 0; x < image.width / 2; x++) {
      final offset = ((image.height ~/ 2) * image.width + x) * 4;
      if (bytes.getUint8(offset) < 96) {
        darkColumns++;
      }
    }

    expect(image.width, greaterThanOrEqualTo(340));
    expect(darkColumns, greaterThanOrEqualTo(110));
  });
}

Future<Uint8List> _sourcePng() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();
  canvas
    ..drawRect(const Rect.fromLTWH(0, 0, 80, 80), paint..color = Colors.black)
    ..drawRect(const Rect.fromLTWH(80, 0, 80, 80), paint..color = Colors.white);
  final image = await recorder.endRecording().toImage(160, 80);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
}

Future<ui.Image> _decodeImage(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}
