import 'package:flutter/material.dart';

import '../../../core/theme/synctasks_color_scheme.dart';

class ReceiptScreenHeader extends StatelessWidget {
  const ReceiptScreenHeader({
    required this.title,
    this.backTooltip = 'Back',
    this.onBack,
    this.trailing,
    this.centerTitle = false,
    super.key,
  });

  final String title;
  final String backTooltip;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            if (onBack != null) ...[
              IconButton(
                tooltip: backTooltip,
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                style: textTheme.titleLarge?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ] else if (centerTitle && onBack != null) ...[
              const SizedBox(width: 56),
            ],
          ],
        ),
      ),
    );
  }
}

class ReceiptBottomActionBar extends StatelessWidget {
  const ReceiptBottomActionBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.scaffold,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: child,
        ),
      ),
    );
  }
}
