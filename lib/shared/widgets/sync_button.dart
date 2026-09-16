import 'package:flutter/material.dart';

import '../../core/theme/synctasks_color_scheme.dart';

class SyncButton extends StatelessWidget {
  const SyncButton.primary({
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.controlPrimary,
          disabledBackgroundColor: colors.textSecondary.withValues(alpha: 0.28),
          foregroundColor: colors.controlForeground,
          disabledForegroundColor: colors.controlForeground.withValues(
            alpha: 0.64,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.controlForeground.withValues(alpha: 0.72),
                ),
              )
            : Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: (onPressed != null && !isLoading)
                      ? colors.controlForeground
                      : colors.controlForeground.withValues(alpha: 0.64),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
