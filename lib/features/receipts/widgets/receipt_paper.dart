import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../data/receipt_repository.dart';

class ReceiptPaperPreview extends StatelessWidget {
  const ReceiptPaperPreview({
    required this.title,
    required this.items,
    required this.includeFolderLabels,
    this.createdAt,
    this.displayNumber,
    this.drawingStrokesJson,
    this.photoPath,
    this.showArtworkPlaceholder = false,
    this.showReceiptMetadata = true,
    this.paperScale = ReceiptPaperScale.composer,
    this.onAddArtwork,
    super.key,
  });

  final String title;
  final List<SavedReceiptItem> items;
  final bool includeFolderLabels;
  final DateTime? createdAt;
  final int? displayNumber;
  final String? drawingStrokesJson;
  final String? photoPath;
  final bool showArtworkPlaceholder;
  final bool showReceiptMetadata;
  final ReceiptPaperScale paperScale;
  final VoidCallback? onAddArtwork;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final ink = colors.textPrimary;
    final secondaryInk = colors.textSecondary;
    final dateLabel = _dateLabel(items);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxWidth),
        child: PhysicalShape(
          clipper: const _ReceiptPaperClipper(),
          color: Colors.white,
          elevation: _elevation,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, _verticalPadding, 24, 24),
            child: DefaultTextStyle(
              style: textTheme.bodyMedium!.copyWith(
                color: ink,
                fontSize: _bodyFontSize,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    key: const ValueKey('receipt-paper-logo'),
                    height: _logoSize,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'SYNCTASKS',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: ink,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _DottedDivider(),
                  if (showReceiptMetadata &&
                      (displayNumber != null || createdAt != null)) ...[
                    const SizedBox(height: 10),
                    if (displayNumber != null)
                      _ReceiptMetaLine(
                        label: 'RECEIPT',
                        value: '#${displayNumber.toString().padLeft(3, '0')}',
                      ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 3),
                      _ReceiptMetaLine(
                        label: 'DATE',
                        value: DateFormat(
                          'd MMM yyyy  h:mm a',
                        ).format(createdAt!).toUpperCase(),
                      ),
                    ],
                    const SizedBox(height: 10),
                    const _DottedDivider(),
                  ],
                  const SizedBox(height: 13),
                  Text(
                    title.trim().isEmpty ? 'Completed tasks' : title.trim(),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: ink,
                      fontSize: _titleFontSize,
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
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (_hasPhotoArtwork) ...[
                    const SizedBox(height: 17),
                    _ReceiptPhotoPreview(photoPath: photoPath!),
                    const SizedBox(height: 15),
                  ] else if (_hasDrawingArtwork) ...[
                    const SizedBox(height: 17),
                    _ReceiptArtworkPreview(strokesJson: drawingStrokesJson!),
                    const SizedBox(height: 15),
                  ] else if (showArtworkPlaceholder) ...[
                    const SizedBox(height: 17),
                    _ReceiptArtworkPlaceholder(onTap: onAddArtwork),
                    const SizedBox(height: 15),
                  ] else
                    const SizedBox(height: 17),
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
                  else ...[
                    _ReceiptItemsTable(
                      items: items,
                      includeFolderLabels: includeFolderLabels,
                      bodyFontSize: _bodyFontSize,
                    ),
                  ],
                  const SizedBox(height: 7),
                  const _DottedDivider(),
                  const SizedBox(height: 11),
                  _ReceiptTotalRow(count: items.length),
                  const SizedBox(height: 8),
                  Text(
                    'THANK YOU FOR SHOWING UP',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: secondaryInk,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  if (!showReceiptMetadata && dateLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateLabel.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        color: secondaryInk,
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
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

  bool get _hasPhotoArtwork => photoPath != null && photoPath!.isNotEmpty;

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

  double get _maxWidth => switch (paperScale) {
    ReceiptPaperScale.composer => 246,
    ReceiptPaperScale.printing => 260,
    ReceiptPaperScale.detail => 258,
  };

  double get _elevation => switch (paperScale) {
    ReceiptPaperScale.composer => 12,
    ReceiptPaperScale.printing => 20,
    ReceiptPaperScale.detail => 18,
  };

  double get _verticalPadding => switch (paperScale) {
    ReceiptPaperScale.composer => 22,
    ReceiptPaperScale.printing => 24,
    ReceiptPaperScale.detail => 22,
  };

  double get _logoSize => switch (paperScale) {
    ReceiptPaperScale.composer => 28,
    ReceiptPaperScale.printing => 30,
    ReceiptPaperScale.detail => 30,
  };

  double get _titleFontSize => switch (paperScale) {
    ReceiptPaperScale.composer => 16,
    ReceiptPaperScale.printing => 17,
    ReceiptPaperScale.detail => 17,
  };

  double get _bodyFontSize => switch (paperScale) {
    ReceiptPaperScale.composer => 12.5,
    ReceiptPaperScale.printing => 12,
    ReceiptPaperScale.detail => 12,
  };
}

enum ReceiptPaperScale { composer, printing, detail }

class _ReceiptMetaLine extends StatelessWidget {
  const _ReceiptMetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.labelSmall?.copyWith(
      color: colors.textPrimary,
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    );
    return Row(
      children: [
        Text(label, style: style),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, textAlign: TextAlign.right, style: style),
        ),
      ],
    );
  }
}

class _ReceiptItemsTable extends StatelessWidget {
  const _ReceiptItemsTable({
    required this.items,
    required this.includeFolderLabels,
    required this.bodyFontSize,
  });

  final List<SavedReceiptItem> items;
  final bool includeFolderLabels;
  final double bodyFontSize;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final headerStyle = textTheme.labelSmall?.copyWith(
      color: colors.textSecondary,
      fontSize: 9.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(width: 26, child: Text('NO', style: headerStyle)),
            Expanded(child: Text('ITEM', style: headerStyle)),
            Text('DONE', style: headerStyle),
          ],
        ),
        const SizedBox(height: 7),
        for (var i = 0; i < items.length; i++)
          _ReceiptItemRow(
            index: i + 1,
            item: items[i],
            includeFolderLabels: includeFolderLabels,
            bodyFontSize: bodyFontSize,
          ),
      ],
    );
  }
}

class _ReceiptItemRow extends StatelessWidget {
  const _ReceiptItemRow({
    required this.index,
    required this.item,
    required this.includeFolderLabels,
    required this.bodyFontSize,
  });

  final int index;
  final SavedReceiptItem item;
  final bool includeFolderLabels;
  final double bodyFontSize;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final taskStyle = textTheme.bodyMedium?.copyWith(
      color: colors.textPrimary,
      fontSize: bodyFontSize,
      height: 1.18,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final sideStyle = textTheme.bodySmall?.copyWith(
      color: colors.textPrimary,
      fontSize: 10,
      height: 1.2,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Text(index.toString().padLeft(2, '0'), style: sideStyle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: taskStyle),
                if (includeFolderLabels && item.folderName != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    item.folderName!.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 9,
                      letterSpacing: 0.7,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('DONE', style: sideStyle),
        ],
      ),
    );
  }
}

class _ReceiptTotalRow extends StatelessWidget {
  const _ReceiptTotalRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.titleMedium?.copyWith(
      color: colors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      children: [
        Text('TOTAL', style: style),
        const Spacer(),
        Text('$count DONE', style: style),
      ],
    );
  }
}

class _ReceiptPaperClipper extends CustomClipper<Path> {
  const _ReceiptPaperClipper();

  @override
  Path getClip(Size size) {
    const scallop = 6.0;
    final path = Path()..moveTo(0, scallop);
    var x = 0.0;
    while (x < size.width) {
      path.quadraticBezierTo(x + scallop / 2, 0, x + scallop, scallop);
      x += scallop;
    }
    path.lineTo(size.width, size.height - scallop);
    x = size.width;
    while (x > 0) {
      path.quadraticBezierTo(
        x - scallop / 2,
        size.height,
        x - scallop,
        size.height - scallop,
      );
      x -= scallop;
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _ReceiptPaperClipper oldClipper) => false;
}

class _ReceiptArtworkPlaceholder extends StatelessWidget {
  const _ReceiptArtworkPlaceholder({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      key: const ValueKey('receipt-paper-artwork-placeholder'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRoundedRectPainter(color: colors.divider),
        child: SizedBox(
          height: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, color: colors.textSecondary, size: 24),
              const SizedBox(height: 8),
              Text(
                'Add photo or drawing',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Optional',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          color: Colors.black,
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

class _ReceiptPhotoPreview extends StatelessWidget {
  const _ReceiptPhotoPreview({required this.photoPath});

  final String photoPath;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      key: const ValueKey('receipt-paper-photo'),
      height: 132,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.divider),
      ),
      child: Image.file(
        File(photoPath),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: colors.textSecondary,
              size: 24,
            ),
          );
        },
      ),
    );
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

class _DashedRoundedRectPainter extends CustomPainter {
  const _DashedRoundedRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + 5);
        canvas.drawPath(segment, paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
