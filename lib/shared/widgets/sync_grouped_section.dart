import 'package:flutter/material.dart';

import '../../core/theme/synctask_color_scheme.dart';

class SyncGroupedSection extends StatelessWidget {
  const SyncGroupedSection({
    required this.children,
    this.dividerIndent = 68,
    super.key,
  });

  final List<Widget> children;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.divider),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                Divider(
                  height: 1,
                  indent: dividerIndent,
                  color: colors.divider,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
