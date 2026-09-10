import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../data/receipt_repository.dart';

class ReceiptPaperPreview extends StatelessWidget {
  const ReceiptPaperPreview({
    required this.title,
    required this.items,
    required this.includeFolderLabels,
    this.createdAt,
    this.displayNumber,
    this.drawingStrokesJson,
    super.key,
  });

  final String title;
  final List<SavedReceiptItem> items;
  final bool includeFolderLabels;
  final DateTime? createdAt;
  final int? displayNumber;
  final String? drawingStrokesJson;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final ink = colors.textPrimary;
    final secondaryInk = colors.textSecondary;
    final dateLabel = _dateLabel(items);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
            child: DefaultTextStyle(
              style: textTheme.bodyMedium!.copyWith(color: ink, fontSize: 13),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(SyncIcons.receipt, size: 28, color: ink),
                  const SizedBox(height: 7),
                  Text(
                    'SYNCTASKS',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _DottedDivider(),
                  const SizedBox(height: 14),
                  Text(
                    title.trim().isEmpty ? 'Completed tasks' : title.trim(),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  if (dateLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      dateLabel.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        color: secondaryInk,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (_hasDrawingArtwork) ...[
                    const SizedBox(height: 18),
                    _ReceiptArtworkPreview(strokesJson: drawingStrokesJson!),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 18),
                  if (items.isEmpty)
                    Text(
                      'Choose completed tasks before generating a receipt.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: secondaryInk,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    )
                  else
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_box_rounded, color: ink, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: ink,
                                      fontSize: 13,
                                      height: 1.22,
                                    ),
                                  ),
                                  if (includeFolderLabels &&
                                      item.folderName != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.folderName!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: secondaryInk,
                                        fontSize: 11,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  const SizedBox(height: 10),
                  const _DottedDivider(),
                  const SizedBox(height: 15),
                  Text(
                    _completedLabel(items.length),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  if (displayNumber != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Receipt #${displayNumber.toString().padLeft(3, '0')}',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: secondaryInk,
                        fontSize: 10,
                      ),
                    ),
                  ],
                  if (createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Generated ${DateFormat('d MMM yyyy, h:mm a').format(createdAt!)}',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: secondaryInk,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasDrawingArtwork =>
      drawingStrokesJson != null && drawingStrokesJson!.isNotEmpty;

  String? _dateLabel(List<SavedReceiptItem> items) {
    if (items.isEmpty) {
      return null;
    }
    final dates = items.map((item) => item.completedAt).toList()..sort();
    final first = dates.first;
    final last = dates.last;
    final sameDay =
        first.year == last.year &&
        first.month == last.month &&
        first.day == last.day;
    final formatter = DateFormat('d MMMM yyyy');
    if (sameDay) {
      return formatter.format(first);
    }
    return '${formatter.format(first)} - ${formatter.format(last)}';
  }

  String _completedLabel(int count) {
    return count == 1 ? '1 task completed' : '$count tasks completed';
  }
}

class _ReceiptArtworkPreview extends StatelessWidget {
  const _ReceiptArtworkPreview({required this.strokesJson});

  final String strokesJson;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      key: const ValueKey('receipt-paper-artwork'),
      height: 132,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.divider),
      ),
      child: CustomPaint(
        painter: _ReceiptDrawingPainter(
          strokes: _decodeStrokes(strokesJson),
          color: colors.textPrimary,
        ),
      ),
    );
  }

  List<List<Offset>> _decodeStrokes(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) {
        return const [];
      }
      return [
        for (final stroke in decoded)
          if (stroke is List)
            [
              for (final point in stroke)
                if (point is List && point.length == 2)
                  Offset(
                    (point[0] as num).toDouble().clamp(0, 1),
                    (point[1] as num).toDouble().clamp(0, 1),
                  ),
            ],
      ];
    } catch (_) {
      return const [];
    }
  }
}

class _ReceiptDrawingPainter extends CustomPainter {
  const _ReceiptDrawingPainter({required this.strokes, required this.color});

  final List<List<Offset>> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) {
        continue;
      }
      final path = Path()
        ..moveTo(stroke.first.dx * size.width, stroke.first.dy * size.height);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ReceiptDrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.color != color;
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DottedDividerPainter(
        color: SyncTasksColorScheme.of(context).divider,
      ),
    );
  }
}

class _DottedDividerPainter extends CustomPainter {
  const _DottedDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
