import 'package:flutter/material.dart';

import '../../core/theme/synctask_color_scheme.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.child,
    this.minHeight,
    this.maxHeight,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 28),
    this.handleGap = 20,
    this.scrollController,
    super.key,
  });

  final Widget child;
  final double? minHeight;
  final double? maxHeight;
  final EdgeInsetsGeometry padding;
  final double handleGap;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
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
