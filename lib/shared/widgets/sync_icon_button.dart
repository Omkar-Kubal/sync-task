import 'package:flutter/material.dart';

import '../../core/theme/synctasks_color_scheme.dart';

class SyncIconButton extends StatelessWidget {
  const SyncIconButton({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: IconButton(
        onPressed: onPressed,
        tooltip: semanticLabel,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        style: IconButton.styleFrom(
          fixedSize: const Size.square(44),
          minimumSize: const Size.square(44),
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          padding: EdgeInsets.zero,
          side: BorderSide(color: colors.divider),
          shape: const CircleBorder(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(icon, size: 22),
      ),
    );
  }
}


