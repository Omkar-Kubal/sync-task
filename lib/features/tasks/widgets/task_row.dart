import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/theme/synctask_color_scheme.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({
    required this.title,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
    this.metadata,
    super.key,
  });

  final String title;
  final String? metadata;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final label = metadata == null ? title : '$title, $metadata';
    return Semantics(
      label: label,
      button: true,
      onTap: onTap,
      onDismiss: onDelete,
      customSemanticsActions: {
        CustomSemanticsAction(label: 'Complete'): onComplete,
        CustomSemanticsAction(label: 'Delete'): onDelete,
      },
      child: Dismissible(
        key: ValueKey(title),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onComplete();
          } else {
            onDelete();
          }
          return false;
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.check, color: colors.textSecondary, size: 22),
          ),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: metadata == null ? null : Text(metadata!),
          onTap: onTap,
        ),
      ),
    );
  }
}
