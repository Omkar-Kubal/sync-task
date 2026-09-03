import 'package:flutter/material.dart';

import '../../core/theme/synctask_color_scheme.dart';

class SyncButton extends StatelessWidget {
  const SyncButton.primary({
    required this.label,
    required this.onPressed,
    this.height = 56,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
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
        child: Text(label),
      ),
    );
  }
}
