import '../domain/recurrence_type.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_empty_state.dart';
import '../../../shared/widgets/sync_fab.dart';
import '../../lists/providers/list_tasks_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../domain/task.dart' as domain;
import '../providers/folders_provider.dart';
import '../providers/task_controller.dart';
import '../providers/today_tasks_provider.dart';
import '../widgets/task_bulk_action_bar.dart';
import '../widgets/task_create_sheet.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/task_metadata.dart';
import '../widgets/task_row.dart';
import 'upcoming_screen.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  final Set<int> _selectedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tasksValue = ref.watch(todayTasksProvider);
    final foldersById = _foldersById(ref.watch(foldersProvider).value);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today',
                        style: textTheme.displaySmall?.copyWith(
                          color: colors.textPrimary,
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${now.day}',
                        style: textTheme.headlineLarge?.copyWith(
                          color: colors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _monthLabel(now.month),
                        style: textTheme.titleLarge?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  key: const Key('today-top-actions-pill'),
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        button: true,
                        label: 'Open Upcoming',
                        child: IconButton(
                          onPressed: () {
                            SyncHaptics.selection();
                            _showUpcomingSheet(context);
                          },
                          style: IconButton.styleFrom(
                            fixedSize: const Size(46, 46),
                            minimumSize: const Size(46, 46),
                            foregroundColor: colors.textPrimary,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const CircleBorder(),
                          ),
                          tooltip: 'Open Upcoming',
                          icon: ExcludeSemantics(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar04,
                              size: 28,
                              color: colors.textPrimary,
                              strokeWidth: 1.5,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: colors.divider,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Search tasks',
                        child: IconButton(
                          onPressed: () {
                            SyncHaptics.selection();
                            context.go('/today/search');
                          },
                          style: IconButton.styleFrom(
                            fixedSize: const Size(46, 46),
                            minimumSize: const Size(46, 46),
                            foregroundColor: colors.textPrimary,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const CircleBorder(),
                          ),
                          tooltip: 'Search',
                          icon: ExcludeSemantics(
                            child: Icon(
                              SyncIcons.search,
                              size: 28,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: colors.divider,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Settings',
                        child: IconButton(
                          key: const Key('today-settings-button'),
                          onPressed: () {
                            SyncHaptics.selection();
                            _showSettingsSheet(context);
                          },
                          style: IconButton.styleFrom(
                            fixedSize: const Size(46, 46),
                            minimumSize: const Size(46, 46),
                            foregroundColor: colors.textPrimary,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const CircleBorder(),
                          ),
                          tooltip: 'Settings',
                          icon: ExcludeSemantics(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSetting07,
                              size: 28,
                              color: colors.textPrimary,
                              strokeWidth: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_selectedTaskIds.isNotEmpty)
              TaskBulkActionBar(
                selectedCount: _selectedTaskIds.length,
                onCancel: _clearSelection,
                onReschedule: () => _showBulkRescheduleSheet(context),
                onMove: () => _showBulkMoveSheet(context),
                onComplete: () => unawaited(_completeSelectedTasks()),
                onDelete: () => unawaited(_deleteSelectedTasks()),
              ),
            Expanded(
              child: _TodayBody(
                tasksValue: tasksValue,
                folderNamesById: foldersById,
                onCreate: () => _showCreateSheet(context, ref),
                onTaskTap: (task) => _showEditSheet(context, ref, task: task),
                selectionMode: _selectedTaskIds.isNotEmpty,
                selectedTaskIds: _selectedTaskIds,
                onTaskLongPress: _selectTask,
                onSelectionToggle: _toggleTaskSelection,
                onComplete: (task) => unawaited(_completeTask(ref, task)),
                onDelete: (task) => unawaited(_deleteTask(ref, task)),
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

  void _selectTask(Task task) {
    setState(() {
      _selectedTaskIds.add(task.id);
    });
  }

  void _toggleTaskSelection(Task task) {
    setState(() {
      if (!_selectedTaskIds.add(task.id)) {
        _selectedTaskIds.remove(task.id);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedTaskIds.clear);
  }

  Future<void> _completeSelectedTasks() async {
    final taskIds = _selectedTaskIds.toList(growable: false);
    if (taskIds.isEmpty) {
      return;
    }
    final folderIds = await _folderIdsFor(taskIds);
    await ref.read(taskControllerProvider).completeTasks(taskIds);
    if (!mounted) {
      return;
    }
    _clearSelection();
    invalidateTaskListProviders(ref, folderIds: folderIds);
  }

  Future<void> _deleteSelectedTasks() async {
    final taskIds = _selectedTaskIds.toList(growable: false);
    if (taskIds.isEmpty) {
      return;
    }
    final folderIds = await _folderIdsFor(taskIds);
    await ref.read(taskControllerProvider).deleteTasks(taskIds);
    if (!mounted) {
      return;
    }
    _clearSelection();
    invalidateTaskListProviders(ref, folderIds: folderIds);
  }

  Future<void> _rescheduleSelectedTasks(DateTime? scheduledDate) async {
    final taskIds = _selectedTaskIds.toList(growable: false);
    if (taskIds.isEmpty) {
      return;
    }
    final folderIds = await _folderIdsFor(taskIds);
    await ref
        .read(taskControllerProvider)
        .rescheduleTasks(taskIds, scheduledDate);
    if (!mounted) {
      return;
    }
    _clearSelection();
    invalidateTaskListProviders(ref, folderIds: folderIds);
  }

  Future<void> _moveSelectedTasksToFolder(int folderId) async {
    final taskIds = _selectedTaskIds.toList(growable: false);
    if (taskIds.isEmpty) {
      return;
    }
    final folderIds = await _folderIdsFor(taskIds)
      ..add(folderId);
    await ref.read(taskControllerProvider).moveTasksToFolder(taskIds, folderId);
    if (!mounted) {
      return;
    }
    _clearSelection();
    invalidateTaskListProviders(ref, folderIds: folderIds);
  }

  Future<Set<int>> _folderIdsFor(Iterable<int> taskIds) async {
    final repository = ref.read(taskRepositoryProvider);
    final folderIds = <int>{};
    for (final taskId in taskIds) {
      final task = await repository.getTask(taskId);
      if (task != null) {
        folderIds.add(task.folderId);
      }
    }
    return folderIds;
  }

  void _showBulkRescheduleSheet(BuildContext context) {
    final today = _todayDate();
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      barrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Today'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_rescheduleSelectedTasks(today));
                },
              ),
              ListTile(
                title: const Text('Tomorrow'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_rescheduleSelectedTasks(tomorrow));
                },
              ),
              ListTile(
                title: const Text('Next week'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_rescheduleSelectedTasks(nextWeek));
                },
              ),
              ListTile(
                title: const Text('No date'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_rescheduleSelectedTasks(null));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBulkMoveSheet(BuildContext context) {
    final folders = ref.read(foldersProvider).value ?? const <Folder>[];
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      barrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final folder in folders)
                ListTile(
                  title: Text(folder.name),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(_moveSelectedTasksToFolder(folder.id));
                  },
                ),
              if (folders.isEmpty)
                const ListTile(title: Text('No folders available')),
            ],
          ),
        );
      },
    );
  }

  void _showUpcomingSheet(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: colors.scaffold,
      constraints: BoxConstraints.tight(MediaQuery.sizeOf(context)),
      builder: (sheetContext) {
        return UpcomingScreen(onClose: () => Navigator.of(sheetContext).pop());
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: colors.scaffold,
      constraints: BoxConstraints.tight(MediaQuery.sizeOf(context)),
      builder: (sheetContext) {
        return SettingsScreen(onClose: () => Navigator.of(sheetContext).pop());
      },
    );
  }

  String _monthLabel(int month) {
    return switch (month) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mar',
      4 => 'Apr',
      5 => 'May',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sept',
      10 => 'Oct',
      11 => 'Nov',
      12 => 'Dec',
      _ => '',
    };
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
            onSubmit: (title, folderId) =>
                unawaited(_createTask(sheetContext, ref, title, folderId)),
            onTodaySelected: (title, folderId) {
              Navigator.of(sheetContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _showEditSheet(context, ref, initialTitle: title.trim());
                }
              });
            },
          ),
        );
      },
    );
  }

  void _showEditSheet(
    BuildContext context,
    WidgetRef ref, {
    Task? task,
    String? initialTitle,
  }) async {
    RecurrenceType? recurrenceType;
    TaskSery? series;
    if (task?.seriesId != null) {
      series = await ref
          .read(taskRepositoryProvider)
          .getSeriesForTask(task!.seriesId!);
      if (series != null) {
        recurrenceType = RecurrenceType.fromStorage(series.repeatType);
      }
    }

    if (!context.mounted) return;

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
            title: task?.title ?? initialTitle ?? '',
            scheduledDate: task?.scheduledDate ?? _todayDate(),
            scheduledTime: task?.scheduledTime,
            reminderTime: task?.reminderTime,
            focusDurationMinutes: task?.focusDurationMinutes,
            recurrenceType: recurrenceType,
            recurrenceInterval: series?.recurrenceInterval,
            customRepeatLabel: series?.customRepeatLabel,
            onCancel: () => Navigator.of(sheetContext).pop(),
            onDone: () => Navigator.of(sheetContext).pop(),
            onSave: task == null
                ? (update) => _createTaskFromUpdate(ref, update)
                : (update) => _updateTask(ref, task, update),
          ),
        );
      },
    );
  }

  Future<void> _createTask(
    BuildContext sheetContext,
    WidgetRef ref,
    String title, [
    int? folderId,
  ]) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final id = await ref
        .read(taskControllerProvider)
        .create(
          domain.TaskDraft(
            title: trimmedTitle,
            folderId: folderId,
            scheduledDate: DateTime(now.year, now.month, now.day),
          ),
        );
    final task = await ref.read(taskRepositoryProvider).getTask(id);
    invalidateTaskListProviders(
      ref,
      folderIds: [
        if (task != null) task.folderId,
        if (folderId != null) folderId,
      ],
    );
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
  }

  Future<void> _createTaskFromUpdate(
    WidgetRef ref,
    TaskEditUpdate update,
  ) async {
    final id = await ref
        .read(taskControllerProvider)
        .create(_draftFromUpdate(update));
    final task = await ref.read(taskRepositoryProvider).getTask(id);
    invalidateTaskListProviders(
      ref,
      folderIds: [if (task != null) task.folderId],
    );
  }

  Future<void> _completeTask(WidgetRef ref, Task task) async {
    await ref.read(taskControllerProvider).complete(task.id);
    invalidateTaskListProviders(ref, folderIds: [task.folderId]);
  }

  Future<void> _updateTask(
    WidgetRef ref,
    Task task,
    TaskEditUpdate update,
  ) async {
    await ref
        .read(taskControllerProvider)
        .updateTask(task.id, _draftFromUpdate(update));
    final updated = await ref.read(taskRepositoryProvider).getTask(task.id);
    invalidateTaskListProviders(
      ref,
      folderIds: [task.folderId, if (updated != null) updated.folderId],
    );
  }

  domain.TaskDraft _draftFromUpdate(TaskEditUpdate update) {
    return domain.TaskDraft(
      title: update.title,
      scheduledDate: update.scheduledDate,
      scheduledTime: update.scheduledTime,
      reminderTime: update.reminderTime,
      focusDurationMinutes: update.focusDurationMinutes,
      recurrenceType: update.recurrenceType,
      recurrenceInterval: update.recurrenceInterval,
      customRepeatLabel: update.customRepeatLabel,
    );
  }

  DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _deleteTask(WidgetRef ref, Task task) async {
    await ref.read(taskControllerProvider).delete(task.id);
    invalidateTaskListProviders(ref, folderIds: [task.folderId]);
  }

  Map<int, String> _foldersById(List<Folder>? folders) {
    if (folders == null) {
      return const {};
    }
    return {for (final folder in folders) folder.id: folder.name};
  }
}

class _TodayBody extends StatelessWidget {
  const _TodayBody({
    required this.tasksValue,
    required this.folderNamesById,
    required this.onCreate,
    required this.onTaskTap,
    required this.onComplete,
    required this.onDelete,
    required this.selectionMode,
    required this.selectedTaskIds,
    required this.onTaskLongPress,
    required this.onSelectionToggle,
  });

  final AsyncValue<List<Task>> tasksValue;
  final Map<int, String> folderNamesById;
  final VoidCallback onCreate;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onComplete;
  final ValueChanged<Task> onDelete;
  final bool selectionMode;
  final Set<int> selectedTaskIds;
  final ValueChanged<Task> onTaskLongPress;
  final ValueChanged<Task> onSelectionToggle;

  @override
  Widget build(BuildContext context) {
    return tasksValue.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _EmptyTodayState(onCreate: onCreate);
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 26, bottom: 108),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskRow(
              title: task.title,
              metadata: taskMetadataFor(
                task,
                folderNamesById: folderNamesById,
                includeDate: false,
              ),
              selectionMode: selectionMode,
              isSelected: selectedTaskIds.contains(task.id),
              onSelectionToggle: () => onSelectionToggle(task),
              onLongPress: () => onTaskLongPress(task),
              onTap: () => onTaskTap(task),
              onComplete: () => onComplete(task),
              onDelete: () => onDelete(task),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 2),
          itemCount: tasks.length,
        );
      },
      loading: () => _EmptyTodayState(onCreate: onCreate),
      error: (error, stackTrace) => _EmptyTodayState(onCreate: onCreate),
    );
  }
}

class _EmptyTodayState extends StatelessWidget {
  const _EmptyTodayState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SyncEmptyState(
      icon: SyncIcons.completed,
      title: "You're clear for today.",
      message: 'Create a task whenever something pops up.',
      actionLabel: 'Create new task',
      onAction: onCreate,
    );
  }
}


