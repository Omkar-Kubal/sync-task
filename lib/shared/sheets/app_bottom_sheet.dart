import 'package:flutter/material.dart';

import '../../core/theme/synctask_color_scheme.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.child,
    this.minHeight,
    this.maxHeight,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 28),
    this.handleGap = 20,
    super.key,
  });

  final Widget child;
  final double? minHeight;
  final double? maxHeight;
  final EdgeInsetsGeometry padding;
  final double handleGap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: colors.divider),
      ),
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
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
            SizedBox(height: handleGap),
            child,
          ],
        ),
      ),
    );
  }
}
