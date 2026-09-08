import '../../../shared/icons/list_filter_icon.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_fab.dart';
import '../../tasks/domain/recurrence_type.dart';
import '../../tasks/domain/task.dart' as domain;
import '../../tasks/providers/completed_tasks_provider.dart';
import '../../tasks/providers/folders_provider.dart';
import '../../tasks/providers/task_controller.dart';
import '../../tasks/widgets/task_create_sheet.dart';
import '../../tasks/widgets/task_edit_sheet.dart';
import '../../tasks/widgets/task_metadata.dart';
import '../../tasks/widgets/task_row.dart';
import '../providers/list_tasks_provider.dart';

class AllTasksScreen extends ConsumerWidget {
  const AllTasksScreen({this.onClose, this.scrollController, super.key});

  final VoidCallback? onClose;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListDetailScreen(
      title: 'All',
      tasksValue: ref.watch(allTasksProvider),
      emptyMessage: 'All active tasks will show up here.',
      onClose: onClose,
      scrollController: scrollController,
    );
  }
}

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({this.onClose, this.scrollController, super.key});

  final VoidCallback? onClose;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListDetailScreen(
      title: 'Reminders',
      tasksValue: ref.watch(reminderTasksProvider),
      emptyMessage: 'Tasks with reminders will show up here.',
      createWithReminder: true,
      onClose: onClose,
      scrollController: scrollController,
    );
  }
}

class InboxTasksScreen extends ConsumerWidget {
  const InboxTasksScreen({this.onClose, this.scrollController, super.key});

  final VoidCallback? onClose;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersValue = ref.watch(foldersProvider);
    final inbox = foldersValue.value
        ?.where((folder) => folder.name == 'Inbox')
        .firstOrNull;
    return ListDetailScreen(
      title: 'Inbox',
      tasksValue: inbox == null
          ? const AsyncLoading<List<Task>>()
          : ref.watch(folderTasksProvider(inbox.id)),
      emptyMessage: 'Inbox tasks will show up here.',
      createFolderId: inbox?.id,
      folderLabel: 'Inbox',
      onClose: onClose,
      scrollController: scrollController,
    );
  }
}

class FolderTasksScreen extends ConsumerWidget {
  const FolderTasksScreen({
    required this.folderId,
    this.onClose,
    this.scrollController,
    super.key,
  });

  final int folderId;
  final VoidCallback? onClose;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersValue = ref.watch(foldersProvider);
    final folders = foldersValue.value;
    final folder = folders
        ?.where((folder) => folder.id == folderId)
        .firstOrNull;

    if (foldersValue.hasValue && folder == null) {
      return _MissingFolderScreen(
        onClose: onClose,
        scrollController: scrollController,
      );
    }

    return ListDetailScreen(
      title: folder?.name ?? 'Folder',
      tasksValue: folder == null
          ? const AsyncLoading<List<Task>>()
          : ref.watch(folderTasksProvider(folderId)),
      emptyMessage: 'Tasks in this folder will show up here.',
      createFolderId: folderId,
      folderLabel: folder?.name ?? 'Folder',
      onClose: onClose,
      scrollController: scrollController,
    );
  }
}

class CompletedTasksScreen extends ConsumerWidget {
  const CompletedTasksScreen({this.onClose, this.scrollController, super.key});

  final VoidCallback? onClose;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListDetailScreen(
      title: 'Completed',
      tasksValue: ref.watch(completedTasksProvider),
      emptyMessage: 'Completed tasks will show up here.',
      showCreateButton: false,
      groupCompletedTasks: true,
      onClose: onClose,
      scrollController: scrollController,
    );
  }
}

class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({
    required this.title,
    required this.tasksValue,
    required this.emptyMessage,
    this.createFolderId,
    this.folderLabel = 'Inbox',
    this.showCreateButton = true,
    this.groupCompletedTasks = false,
    this.createWithReminder = false,
    this.onClose,
    this.scrollController,
    super.key,
  });

  final String title;
  final AsyncValue<List<Task>> tasksValue;
  final String emptyMessage;
  final int? createFolderId;
  final String folderLabel;
  final bool showCreateButton;
  final bool groupCompletedTasks;
  final bool createWithReminder;
  final VoidCallback? onClose;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope<void>(
      canPop: onClose != null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _returnToLists(context);
        }
      },
      child: Scaffold(
        backgroundColor: SyncTasksColorScheme.of(context).scaffold,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ListDetailHeader(
                onClose: () => _returnToLists(context),
                title: title,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: tasksValue.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return _EmptyListState(
                        message: emptyMessage,
                        scrollController: scrollController,
                        onCreate: showCreateButton
                            ? () => _showCreateSheet(context, ref)
                            : null,
                      );
                    }
                    if (groupCompletedTasks) {
                      return _CompletedTaskList(
                        tasks: tasks,
                        scrollController: scrollController,
                        onTaskTap: (task) => _showEditSheet(context, ref, task),
                        onRestore: (task) => unawaited(_restoreTask(ref, task)),
                        onDelete: (task) => unawaited(_deleteTask(ref, task)),
                      );
                    }
                    return _PlainTaskList(
                      tasks: tasks,
                      scrollController: scrollController,
                      onTaskTap: (task) => _showEditSheet(context, ref, task),
                      onComplete: (task) => unawaited(_completeTask(ref, task)),
                      onDelete: (task) => unawaited(_deleteTask(ref, task)),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => _EmptyListState(
                    message: 'Could not load this list.',
                    scrollController: scrollController,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _showFloatingCreateButton(tasksValue)
            ? Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 8),
                child: SyncFab(
                  onPressed: () => _showCreateSheet(context, ref),
                  semanticLabel: 'Create task',
                ),
              )
            : null,
      ),
    );
  }

  bool _showFloatingCreateButton(AsyncValue<List<Task>> tasksValue) {
    final tasks = tasksValue.value;
    return showCreateButton && tasks != null && tasks.isNotEmpty;
  }

  void _returnToLists(BuildContext context) {
    final close = onClose;
    if (close == null) {
      context.go('/lists');
    } else {
      close();
    }
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
            folderLabel: folderLabel,
            initialFolderId: createFolderId,
            onSubmit: (title, chosenFolderId) => unawaited(
              _createTask(sheetContext, ref, title, chosenFolderId),
            ),
            onTodaySelected: (title, chosenFolderId) {
              Navigator.of(sheetContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _showEditSheet(
                    context,
                    ref,
                    null,
                    initialTitle: title.trim(),
                    initialScheduledDate: _todayDate(),
                    initialReminderTime: createWithReminder
                        ? _defaultReminderTime()
                        : null,
                  );
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
    WidgetRef ref,
    Task? task, {
    String? initialTitle,
    DateTime? initialScheduledDate,
    DateTime? initialReminderTime,
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
            scheduledDate: task?.scheduledDate ?? initialScheduledDate,
            scheduledTime: task?.scheduledTime,
            reminderTime: task?.reminderTime ?? initialReminderTime,
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

    final id = await ref
        .read(taskControllerProvider)
        .create(
          domain.TaskDraft(
            title: trimmedTitle,
            folderId: folderId,
            reminderTime: createWithReminder ? _defaultReminderTime() : null,
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
        .create(_draftFromUpdate(update, defaultReminder: createWithReminder));
    final task = await ref.read(taskRepositoryProvider).getTask(id);
    invalidateTaskListProviders(
      ref,
      folderIds: [if (task != null) task.folderId],
    );
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

  Future<void> _completeTask(WidgetRef ref, Task task) async {
    await ref.read(taskControllerProvider).complete(task.id);
    invalidateTaskListProviders(ref, folderIds: [task.folderId]);
  }

  Future<void> _restoreTask(WidgetRef ref, Task task) async {
    await ref
        .read(taskControllerProvider)
        .restore(domain.TaskSnapshot(taskId: task.id));
    invalidateTaskListProviders(ref, folderIds: [task.folderId]);
  }

  Future<void> _deleteTask(WidgetRef ref, Task task) async {
    await ref.read(taskControllerProvider).delete(task.id);
    invalidateTaskListProviders(ref, folderIds: [task.folderId]);
  }

  domain.TaskDraft _draftFromUpdate(
    TaskEditUpdate update, {
    bool defaultReminder = false,
  }) {
    return domain.TaskDraft(
      title: update.title,
      folderId: createFolderId,
      scheduledDate: update.scheduledDate,
      scheduledTime: update.scheduledTime,
      reminderTime:
          update.reminderTime ??
          (defaultReminder ? _defaultReminderTime() : null),
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

  DateTime _defaultReminderTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }
}

class _ListDetailHeader extends StatelessWidget {
  const _ListDetailHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colors.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'Close list',
          child: ExcludeSemantics(
            child: IconButton(
              onPressed: () {
                SyncHaptics.selection();
                onClose();
              },
              tooltip: 'Close list',
              style: IconButton.styleFrom(
                fixedSize: const Size(38, 38),
                minimumSize: const Size(38, 38),
                foregroundColor: colors.textPrimary,
                backgroundColor: colors.surface,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlainTaskList extends StatelessWidget {
  const _PlainTaskList({
    required this.tasks,
    required this.onTaskTap,
    required this.onComplete,
    required this.onDelete,
    this.scrollController,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onComplete;
  final ValueChanged<Task> onDelete;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 2, bottom: 108),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskRow(
          title: task.title,
          metadata: _metadataFor(task),
          onTap: () => onTaskTap(task),
          onComplete: () => onComplete(task),
          onDelete: () => onDelete(task),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 1),
      itemCount: tasks.length,
    );
  }
}

class _CompletedTaskList extends StatelessWidget {
  const _CompletedTaskList({
    required this.tasks,
    required this.onTaskTap,
    required this.onRestore,
    required this.onDelete,
    this.scrollController,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onRestore;
  final ValueChanged<Task> onDelete;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final sections = _sectionsFor(tasks);
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 2, bottom: 32),
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (index > 0) const SizedBox(height: 16),
            _SectionHeader(label: section.label),
            const SizedBox(height: 8),
            ...section.tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: TaskRow(
                  title: task.title,
                  metadata: _metadataFor(task),
                  onTap: () => onTaskTap(task),
                  onComplete: () => onRestore(task),
                  onDelete: () => onDelete(task),
                  isCompleted: true,
                  textState: TaskRowTextState.completed,
                ),
              ),
            ),
          ],
        );
      },
      itemCount: sections.length,
    );
  }

  List<_TaskSection> _sectionsFor(List<Task> tasks) {
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final todayTasks = <Task>[];
    final yesterdayTasks = <Task>[];
    final earlierTasks = <Task>[];

    for (final task in tasks) {
      final completedAt = task.completedAt;
      if (completedAt == null) {
        earlierTasks.add(task);
        continue;
      }
      final date = _dateOnly(completedAt);
      if (date == today) {
        todayTasks.add(task);
      } else if (date == yesterday) {
        yesterdayTasks.add(task);
      } else {
        earlierTasks.add(task);
      }
    }

    return [
      if (todayTasks.isNotEmpty) _TaskSection('TODAY', todayTasks),
      if (yesterdayTasks.isNotEmpty) _TaskSection('YESTERDAY', yesterdayTasks),
      if (earlierTasks.isNotEmpty) _TaskSection('EARLIER', earlierTasks),
    ];
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _TaskSection {
  const _TaskSection(this.label, this.tasks);

  final String label;
  final List<Task> tasks;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: colors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _EmptyListState extends StatelessWidget {
  const _EmptyListState({
    required this.message,
    this.scrollController,
    this.onCreate,
  });

  final String message;
  final ScrollController? scrollController;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Transform.translate(
                      offset: const Offset(0, -8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListFilterIcon(
                            color: colors.textSecondary,
                            size: 34,
                            strokeWidth: 1.8,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'No tasks found',
                            style: textTheme.titleLarge?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                              height: 1.12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              height: 1.34,
                            ),
                          ),
                          if (onCreate != null) ...[
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: () {
                                SyncHaptics.action();
                                onCreate!();
                              },
                              style: FilledButton.styleFrom(
                                fixedSize: const Size(160, 40),
                                minimumSize: const Size(160, 40),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                              ),
                              child: Text(
                                'Create new task',
                                style: textTheme.titleMedium?.copyWith(
                                  color: colors.controlForeground,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MissingFolderScreen extends StatelessWidget {
  const _MissingFolderScreen({this.onClose, this.scrollController});

  final VoidCallback? onClose;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return ListDetailScreen(
      title: 'Folder',
      tasksValue: const AsyncData([]),
      emptyMessage: 'This folder no longer exists.',
      showCreateButton: false,
      onClose: onClose,
      scrollController: scrollController,
    );
  }
}

String? _metadataFor(Task task) {
  return taskMetadataFor(task);
}
