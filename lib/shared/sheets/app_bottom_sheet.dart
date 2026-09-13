import 'package:flutter/material.dart';

import '../../core/theme/synctasks_color_scheme.dart';
import '../motion/sync_motion.dart';
import 'app_sheet_shadow.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.child,
    this.minHeight,
    this.maxHeight,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 28),
    this.handleGap = 20,
    this.showHandle = true,
    this.scrollController,
    super.key,
  });

  final Widget child;
  final double? minHeight;
  final double? maxHeight;
  final EdgeInsetsGeometry padding;
  final double handleGap;
  final bool showHandle;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: AppSheetShadow.decoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: AnimatedSize(
          duration: SyncMotion.sheetDuration,
          reverseDuration: SyncMotion.sheetReverseDuration,
          curve: SyncMotion.enterCurve,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                SizedBox(height: handleGap),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
