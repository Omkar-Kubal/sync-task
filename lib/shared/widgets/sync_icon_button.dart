import 'package:flutter/material.dart';

import '../../core/theme/synctask_color_scheme.dart';

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
    final colors = SyncTaskColorScheme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: IconButton(
        onPressed: onPressed,
        tooltip: semanticLabel,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        style: IconButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.textPrimary),
          shape: const CircleBorder(),
        ),
        icon: Icon(icon),
      ),
    );
  }
}
