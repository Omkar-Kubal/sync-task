import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/motion/sync_motion.dart';
import '../../../shared/services/sync_haptics.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({
    required this.title,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
    this.metadata,
    this.isCompleted = false,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
    this.onLongPress,
    super.key,
  });

  final String title;
  final String? metadata;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final bool isCompleted;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final label = metadata == null ? title : '$title, $metadata';
    final showCheckmark = selectionMode ? isSelected : isCompleted;
    void handleTap() {
      SyncHaptics.selection();
      if (selectionMode) {
        onSelectionToggle?.call();
      } else {
        onTap();
      }
    }

    void handleComplete() {
      SyncHaptics.complete();
      if (selectionMode) {
        onSelectionToggle?.call();
      } else {
        onComplete();
      }
    }

    void handleDelete() {
      SyncHaptics.destructive();
      onDelete();
    }

    return Semantics(
      label: label,
      button: true,
      onTap: handleTap,
      onDismiss: selectionMode ? null : handleDelete,
      customSemanticsActions: {
        if (selectionMode)
          CustomSemanticsAction(label: isSelected ? 'Deselect' : 'Select'):
              handleTap
        else ...{
          CustomSemanticsAction(label: isCompleted ? 'Restore' : 'Complete'):
              handleComplete,
          CustomSemanticsAction(label: 'Delete'): handleDelete,
        },
      },
      child: Dismissible(
        key: ValueKey(title),
        direction: selectionMode
            ? DismissDirection.none
            : DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            handleComplete();
          } else {
            handleDelete();
          }
          return false;
        },
        child: InkWell(
          onTap: handleTap,
          onLongPress: () {
            SyncHaptics.selection();
            onLongPress?.call();
          },
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  label: selectionMode
                      ? (isSelected ? 'Deselect task' : 'Select task')
                      : (isCompleted ? 'Restore task' : 'Complete task'),
                  child: InkResponse(
                    key: const Key('task-row-checkbox-button'),
                    onTap: handleComplete,
                    radius: 17,
                    customBorder: const CircleBorder(),
                    child: SizedBox.square(
                      dimension: 44,
                      child: Center(
                        child: AnimatedScale(
                          key: const Key('task-row-checkbox-completion-scale'),
                          scale: showCheckmark ? 1.08 : 1,
                          duration: SyncMotion.shortDuration,
                          curve: SyncMotion.enterCurve,
                          child: Container(
                            key: const Key('task-row-checkbox'),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: showCheckmark ? colors.textPrimary : null,
                              border: Border.all(
                                color: colors.textPrimary,
                                width: 1.6,
                              ),
                            ),
                            child: AnimatedSwitcher(
                              key: const Key(
                                'task-row-checkbox-completion-switcher',
                              ),
                              duration: SyncMotion.shortDuration,
                              reverseDuration: SyncMotion.microDuration,
                              switchInCurve: SyncMotion.enterCurve,
                              switchOutCurve: SyncMotion.exitCurve,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: showCheckmark
                                  ? Icon(
                                      Icons.check_rounded,
                                      key: const Key(
                                        'task-row-checkbox-completed-icon',
                                      ),
                                      size: 15,
                                      color: colors.scaffold,
                                    )
                                  : const SizedBox.shrink(
                                      key: Key(
                                        'task-row-checkbox-incomplete-icon',
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                              height: 1.08,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: colors.textSecondary,
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
                                color: colors.textSecondary.withValues(
                                  alpha: 0.82,
                                ),
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


