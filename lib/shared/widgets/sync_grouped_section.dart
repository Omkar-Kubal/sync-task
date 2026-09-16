import 'package:flutter/material.dart';

import '../../core/theme/synctasks_color_scheme.dart';

class SyncGroupedSection extends StatelessWidget {
  const SyncGroupedSection({
    required this.children,
    this.dividerIndent = 68,
    super.key,
  });

  final List<Widget> children;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final child in children) child,
          ],
        ),
      ),
    );
  }
}


