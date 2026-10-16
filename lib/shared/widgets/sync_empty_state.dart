import 'package:flutter/material.dart';

import '../../core/theme/synctasks_color_scheme.dart';
import '../../core/theme/sync_typography.dart';
import '../services/sync_haptics.dart';
import '../services/sync_sounds.dart';

class SyncEmptyState extends StatelessWidget {
  const SyncEmptyState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: colors.textSecondary, size: 34),
                const SizedBox(height: 18),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: SyncTypography.of(
                  context,
                ).cardTitle.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: SyncTypography.of(
                  context,
                ).supporting.copyWith(color: colors.textSecondary),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    SyncHaptics.action();
                    SyncSounds.play(SyncSoundEffect.action);
                    onAction!();
                  },
                  style: FilledButton.styleFrom(
                    fixedSize: const Size(160, 40),
                    minimumSize: const Size(160, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: SyncTypography.of(context).button,
                  ),
                  child: Text(
                    actionLabel!,
                    style: SyncTypography.of(
                      context,
                    ).button.copyWith(color: colors.controlForeground),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
