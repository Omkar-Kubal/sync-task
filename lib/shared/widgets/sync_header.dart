import 'package:flutter/material.dart';

import '../../core/theme/sync_typography.dart';

class SyncHeader extends StatelessWidget {
  const SyncHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(20, 18, 20, 16)
          : const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        crossAxisAlignment: compact
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SyncTypography.of(context).pageTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: SyncTypography.of(context).supporting),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
