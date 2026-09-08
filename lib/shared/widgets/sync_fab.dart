import 'package:flutter/material.dart';

import '../../core/theme/synctasks_color_scheme.dart';
import '../icons/sync_icons.dart';
import '../services/sync_haptics.dart';

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
    final colors = SyncTasksColorScheme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 56,
        child: FloatingActionButton(
          onPressed: () {
            SyncHaptics.action();
            onPressed();
          },
          tooltip: semanticLabel,
          elevation: 0,
          backgroundColor: colors.controlPrimary,
          foregroundColor: colors.controlForeground,
          shape: const CircleBorder(),
          child: const Icon(SyncIcons.create, size: 34),
        ),
      ),
    );
  }
}


