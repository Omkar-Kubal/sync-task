import 'package:flutter/material.dart';

import '../../core/theme/synctask_color_scheme.dart';

class SyncFab extends StatelessWidget {
  const SyncFab({
    required this.onPressed,
    required this.semanticLabel,
    super.key,
  });

  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 64,
        child: FloatingActionButton(
          onPressed: onPressed,
          tooltip: semanticLabel,
          elevation: 0,
          backgroundColor: colors.controlPrimary,
          foregroundColor: colors.controlForeground,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 40),
        ),
      ),
    );
  }
}
