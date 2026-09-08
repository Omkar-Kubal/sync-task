import 'package:flutter/material.dart';

import '../../../core/theme/synctasks_color_scheme.dart';

class TaskBulkActionBar extends StatelessWidget {
  const TaskBulkActionBar({
    required this.selectedCount,
    required this.onCancel,
    required this.onReschedule,
    required this.onMove,
    required this.onComplete,
    required this.onDelete,
    super.key,
  });

  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final VoidCallback onMove;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Text(
            '$selectedCount selected',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _BulkActionButton(
                    label: 'Reschedule',
                    semanticLabel: 'Reschedule selected tasks',
                    icon: Icons.event_rounded,
                    onPressed: onReschedule,
                  ),
                  _BulkActionButton(
                    label: 'Move',
                    semanticLabel: 'Move selected tasks',
                    icon: Icons.folder_open_rounded,
                    onPressed: onMove,
                  ),
                  _BulkActionButton(
                    label: 'Complete',
                    semanticLabel: 'Complete selected tasks',
                    icon: Icons.check_rounded,
                    onPressed: onComplete,
                  ),
                  _BulkActionButton(
                    label: 'Delete',
                    semanticLabel: 'Delete selected tasks',
                    icon: Icons.delete_outline_rounded,
                    destructive: true,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cancel selection',
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _BulkActionButton extends StatelessWidget {
  const _BulkActionButton({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final foreground = destructive
        ? Theme.of(context).colorScheme.error
        : colors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foreground,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
        ),
      ),
    );
  }
}


