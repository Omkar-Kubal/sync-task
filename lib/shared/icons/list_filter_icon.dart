import 'package:flutter/material.dart';

class ListFilterIcon extends StatelessWidget {
  const ListFilterIcon({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 1.5,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ListFilterPainter(color: iconColor, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _ListFilterPainter extends CustomPainter {
  const _ListFilterPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * scaleX
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(
      Offset(5 * scaleX, 7 * scaleY),
      Offset(19 * scaleX, 7 * scaleY),
      paint,
    );
    canvas.drawLine(
      Offset(5 * scaleX, 12 * scaleY),
      Offset(15 * scaleX, 12 * scaleY),
      paint,
    );
    canvas.drawLine(
      Offset(5 * scaleX, 17 * scaleY),
      Offset(11 * scaleX, 17 * scaleY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ListFilterPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}


