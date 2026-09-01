import 'package:flutter/material.dart';

import '../../core/theme/synctask_color_scheme.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({required this.child, this.minHeight, super.key});

  final Widget child;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: colors.divider),
      ),
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight!),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
