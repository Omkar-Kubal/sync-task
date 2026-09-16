import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final receiptPhotoProcessorProvider = Provider<ReceiptPhotoProcessor>(
  (ref) => const HalftoneReceiptPhotoProcessor(),
);

abstract class ReceiptPhotoProcessor {
  const ReceiptPhotoProcessor();

  Future<String> processPhoto(String sourcePath);
}

class HalftoneReceiptPhotoProcessor implements ReceiptPhotoProcessor {
  const HalftoneReceiptPhotoProcessor({
    this.maxWidth = 360,
    this.cellSize = 6,
  });

  final int maxWidth;
  final int cellSize;

  @override
  Future<String> processPhoto(String sourcePath) async {
    final sourceFile = File(sourcePath);
    final image = await _decodeImage(await sourceFile.readAsBytes());
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) {
        throw StateError('Could not read photo pixels.');
      }
      final processed = await _drawHalftone(image, data);
      try {
        final png = await processed.toByteData(format: ui.ImageByteFormat.png);
        if (png == null) {
          throw StateError('Could not encode pixelite photo.');
        }
        final outputPath = _outputPathFor(sourcePath);
        await File(outputPath).writeAsBytes(png.buffer.asUint8List());
        return outputPath;
      } finally {
        processed.dispose();
      }
    } finally {
      image.dispose();
    }
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: maxWidth);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> _drawHalftone(ui.Image source, ByteData pixels) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final width = source.width;
    final height = source.height;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = Colors.white,
    );

    final dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    final cell = math.max(3, cellSize);
    for (var y = 0; y < height; y += cell) {
      for (var x = 0; x < width; x += cell) {
        final darkness = _cellDarkness(
          pixels,
          width: width,
          height: height,
          left: x,
          top: y,
          size: cell,
        );
        final boosted = ((darkness - 0.12) / 0.72).clamp(0.0, 1.0);
        if (boosted <= 0) {
          continue;
        }
        final radius = (cell * 0.54 * math.pow(boosted, 0.66)).toDouble();
        canvas.drawCircle(Offset(x + cell / 2, y + cell / 2), radius, dotPaint);
      }
    }

    return recorder.endRecording().toImage(width, height);
  }

  double _cellDarkness(
    ByteData pixels, {
    required int width,
    required int height,
    required int left,
    required int top,
    required int size,
  }) {
    var total = 0.0;
    var count = 0;
    final right = math.min(left + size, width);
    final bottom = math.min(top + size, height);
    for (var y = top; y < bottom; y++) {
      for (var x = left; x < right; x++) {
        final offset = (y * width + x) * 4;
        final red = pixels.getUint8(offset);
        final green = pixels.getUint8(offset + 1);
        final blue = pixels.getUint8(offset + 2);
        final luma = red * 0.299 + green * 0.587 + blue * 0.114;
        total += 1 - (luma / 255);
        count++;
      }
    }
    return count == 0 ? 0 : total / count;
  }

  String _outputPathFor(String sourcePath) {
    final directory = p.dirname(sourcePath);
    final name = p.basenameWithoutExtension(sourcePath);
    return p.join(directory, '${name}_pixelite.png');
  }
}
