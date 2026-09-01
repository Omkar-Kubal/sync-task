import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctask_color_scheme.dart';
import '../../../shared/widgets/sync_fab.dart';
import '../domain/task.dart' as domain;
import '../providers/task_controller.dart';
import '../providers/today_tasks_provider.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../widgets/task_create_sheet.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/task_row.dart';

class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final colors = SyncTaskColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tasksValue = ref.watch(upcomingTasksProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Upcoming',
                    style: textTheme.displaySmall?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'More options',
                  child: IconButton(
                    onPressed: () => _showMoreMenu(context),
                    tooltip: 'More options',
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.textPrimary,
                      padding: EdgeInsets.zero,
                      side: BorderSide.none,
                      shape: const CircleBorder(),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.more_horiz, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              _subtitleFor(now),
              style: textTheme.titleLarge?.copyWith(
                color: colors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: _UpcomingTaskList(
                tasksValue: tasksValue,
                onTaskTap: (task) => _showEditSheet(context, ref, task: task),
                onComplete: (task) => unawaited(_completeTask(ref, task.id)),
                onDelete: (task) => unawaited(_deleteTask(ref, task.id)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 8),
        child: SyncFab(
          onPressed: () => _showCreateSheet(context, ref),
          semanticLabel: 'Create task',
        ),
      ),
    );
  }

  Future<void> _showMoreMenu(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: colors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
    );

    return showMenu<void>(
      context: context,
      color: colors.surface,
      elevation: 10,
      shadowColor: colors.textPrimary.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.divider),
        borderRadius: BorderRadius.circular(18),
      ),
      position: RelativeRect.fromLTRB(screenWidth - 212, 64, 20, 0),
      items: [
        PopupMenuItem<void>(
          height: 54,
          child: _UpcomingMenuRow(
            icon: Icons.tune,
            label: 'View',
            textStyle: textStyle,
          ),
        ),
        PopupMenuDivider(height: 1, color: colors.divider),
        PopupMenuItem<void>(
          height: 54,
          child: _UpcomingMenuRow(
            icon: Icons.copy_outlined,
            label: 'Select tasks',
            textStyle: textStyle,
          ),
        ),
      ],
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      barrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: TaskCreateSheet(
            onSubmit: (title) =>
                unawaited(_createUpcomingTask(sheetContext, ref, title)),
            onTodaySelected: () {
              Navigator.of(sheetContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _showEditSheet(context, ref);
                }
              });
            },
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, {Task? task}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      barrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: TaskEditSheet(
            title: task?.title ?? '',
            scheduledDate: task?.scheduledDate,
            focusDurationMinutes: task?.focusDurationMinutes ?? 45,
            onCancel: () => Navigator.of(sheetContext).pop(),
            onDone: () => Navigator.of(sheetContext).pop(),
            onStartFocus: () => Navigator.of(sheetContext).pop(),
            onSaveTitle: task == null
                ? null
                : (title) => _updateTaskTitle(ref, task.id, title),
          ),
        );
      },
    );
  }

  Future<void> _createUpcomingTask(
    BuildContext sheetContext,
    WidgetRef ref,
    String title,
  ) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await ref
        .read(taskControllerProvider)
        .create(
          domain.TaskDraft(
            title: trimmedTitle,
            scheduledDate: DateTime(
              tomorrow.year,
              tomorrow.month,
              tomorrow.day,
            ),
          ),
        );
    _invalidateTaskLists(ref);
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
  }

  Future<void> _completeTask(WidgetRef ref, int taskId) async {
    await ref.read(taskControllerProvider).complete(taskId);
    _invalidateTaskLists(ref);
  }

  Future<void> _updateTaskTitle(WidgetRef ref, int taskId, String title) async {
    await ref.read(taskControllerProvider).updateTitle(taskId, title);
    _invalidateTaskLists(ref);
  }

  Future<void> _deleteTask(WidgetRef ref, int taskId) async {
    await ref.read(taskControllerProvider).delete(taskId);
    _invalidateTaskLists(ref);
  }

  void _invalidateTaskLists(WidgetRef ref) {
    ref.invalidate(todayTasksProvider);
    ref.invalidate(upcomingTasksProvider);
  }

  String _subtitleFor(DateTime value) {
    return '${DateFormat('MMM d').format(value)} · Today · ${DateFormat('EEEE').format(value)}';
  }
}

class _UpcomingTaskList extends StatelessWidget {
  const _UpcomingTaskList({
    required this.tasksValue,
    required this.onTaskTap,
    required this.onComplete,
    required this.onDelete,
  });

  final AsyncValue<List<Task>> tasksValue;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onComplete;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    return tasksValue.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 108),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskRow(
              title: task.title,
              metadata: 'Inbox',
              onTap: () => onTaskTap(task),
              onComplete: () => onComplete(task),
              onDelete: () => onDelete(task),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: tasks.length,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _UpcomingMenuRow extends StatelessWidget {
  const _UpcomingMenuRow({
    required this.icon,
    required this.label,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Row(
      children: [
        Icon(icon, color: colors.textPrimary, size: 22),
        const SizedBox(width: 18),
        Text(label, style: textStyle),
      ],
    );
  }
}
