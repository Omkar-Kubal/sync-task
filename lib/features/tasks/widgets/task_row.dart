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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  label: 'Complete task',
                  child: InkResponse(
                    key: const Key('task-row-checkbox-button'),
                    onTap: onComplete,
                    radius: 18,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 2,
                        right: 2,
                        bottom: 2,
                      ),
                      child: Container(
                        key: const Key('task-row-checkbox'),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.textPrimary,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                              height: 1.08,
                            ),
                      ),
                      if (metadata != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          metadata!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                                height: 1.1,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
