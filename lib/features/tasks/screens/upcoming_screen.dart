import '../domain/recurrence_type.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_empty_state.dart';
import '../../../shared/widgets/sync_fab.dart';
import '../../lists/providers/list_tasks_provider.dart';
import '../domain/task.dart' as domain;
import '../providers/folders_provider.dart';
import '../providers/task_controller.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../widgets/task_create_sheet.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/task_metadata.dart';
import '../widgets/task_row.dart';

enum _UpcomingView {
  agenda('Agenda'),
  week('Week'),
  overdue('Overdue'),
  noDate('No date'),
  folders('Folders');

  const _UpcomingView(this.label);

  final String label;
}

class UpcomingScreen extends ConsumerStatefulWidget {
  const UpcomingScreen({this.onClose, super.key});

  final VoidCallback? onClose;

  @override
  ConsumerState<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends ConsumerState<UpcomingScreen> {
  _UpcomingView _selectedView = _UpcomingView.agenda;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tasksValue = ref.watch(upcomingTasksProvider);
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
                  child: Text(
                    'Upcoming',
                    style: textTheme.displaySmall?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      height: 1.18,
                    ),
                  ),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: 12),
                  Semantics(
                    button: true,
                    label: 'Close Upcoming',
                    child: IconButton(
                      onPressed: () {
                        SyncHaptics.selection();
                        widget.onClose!();
                      },
                      tooltip: 'Close',
                      constraints: BoxConstraints.tightFor(
                        width: 38,
                        height: 38,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface,
                        foregroundColor: colors.textPrimary,
                        padding: EdgeInsets.zero,
                        side: BorderSide.none,
                        shape: const CircleBorder(),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(SyncIcons.close, size: 22),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _subtitleFor(now),
              style: textTheme.titleLarge?.copyWith(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 22),
            _UpcomingViewChips(
              selectedView: _selectedView,
              onSelected: (view) {
                SyncHaptics.selection();
                setState(() => _selectedView = view);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _UpcomingTaskList(
                tasksValue: tasksValue,
                view: _selectedView,
                folderNamesById: foldersById,
                onTaskTap: (task) => _showEditSheet(context, ref, task: task),
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
            onSubmit: (title, folderId) => unawaited(
              _createUpcomingTask(sheetContext, ref, title, folderId),
            ),
            onTodaySelected: (title, folderId) {
              Navigator.of(sheetContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _showEditSheet(
                    context,
                    ref,
                    initialTitle: title.trim(),
                    initialScheduledDate: _todayDate(),
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
    WidgetRef ref, {
    Task? task,
    String? initialTitle,
    DateTime? initialScheduledDate,
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
            scheduledDate:
                task?.scheduledDate ?? initialScheduledDate ?? _tomorrowDate(),
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

  Future<void> _createUpcomingTask(
    BuildContext sheetContext,
    WidgetRef ref,
    String title, [
    int? folderId,
  ]) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final id = await ref
        .read(taskControllerProvider)
        .create(
          domain.TaskDraft(
            title: trimmedTitle,
            folderId: folderId,
            scheduledDate: DateTime(
              tomorrow.year,
              tomorrow.month,
              tomorrow.day,
            ),
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

  DateTime _tomorrowDate() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
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

  String _subtitleFor(DateTime value) {
    return '${DateFormat('MMM d').format(value)} · Today · ${DateFormat('EEEE').format(value)}';
  }
}

class _UpcomingViewChips extends StatelessWidget {
  const _UpcomingViewChips({
    required this.selectedView,
    required this.onSelected,
  });

  final _UpcomingView selectedView;
  final ValueChanged<_UpcomingView> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final view in _UpcomingView.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(view.label),
                selected: selectedView == view,
                onSelected: (_) => onSelected(view),
                showCheckmark: false,
                selectedColor: colors.textPrimary,
                backgroundColor: colors.surface,
                labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selectedView == view
                      ? colors.controlForeground
                      : colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UpcomingTaskList extends StatelessWidget {
  const _UpcomingTaskList({
    required this.tasksValue,
    required this.view,
    required this.folderNamesById,
    required this.onTaskTap,
    required this.onComplete,
    required this.onDelete,
  });

  final AsyncValue<List<Task>> tasksValue;
  final _UpcomingView view;
  final Map<int, String> folderNamesById;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onComplete;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    return tasksValue.when(
      data: (tasks) {
        final sections = _sectionsFor(tasks);
        if (sections.isEmpty) {
          return _EmptyUpcomingState(
            title: _emptyTitleFor(view),
            message: _emptyMessageFor(view),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 108),
          itemBuilder: (context, index) {
            final section = sections[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (index > 0)
                  _UpcomingSectionDivider(
                    key: Key('upcoming-section-divider-${index - 1}'),
                  ),
                _UpcomingSectionHeader(key: section.key, label: section.label),
                const SizedBox(height: 10),
                ...section.tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TaskRow(
                      title: task.title,
                      metadata: taskMetadataFor(
                        task,
                        folderNamesById: folderNamesById,
                      ),
                      onTap: () => onTaskTap(task),
                      onComplete: () => onComplete(task),
                      onDelete: () => onDelete(task),
                    ),
                  ),
                ),
              ],
            );
          },
          itemCount: sections.length,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const _EmptyUpcomingState(
        title: 'Could not load upcoming tasks',
        message: 'Try again in a moment.',
      ),
    );
  }

  List<_UpcomingTaskSection> _sectionsFor(List<Task> tasks) {
    final today = _dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    return switch (view) {
      _UpcomingView.agenda => _dateSections(
        tasks.where((task) {
          final date = task.scheduledDate;
          return date != null && !_dateOnly(date).isBefore(today);
        }),
        today,
        tomorrow,
      ),
      _UpcomingView.week => _dateSections(
        tasks.where((task) {
          final date = task.scheduledDate;
          if (date == null) {
            return false;
          }
          final day = _dateOnly(date);
          return !day.isBefore(today) &&
              day.isBefore(today.add(const Duration(days: 7)));
        }),
        today,
        tomorrow,
      ),
      _UpcomingView.overdue => [
        _UpcomingTaskSection(
          label: 'Overdue',
          key: const Key('upcoming-section-overdue'),
          tasks: tasks.where((task) {
            final date = task.scheduledDate;
            return date != null && _dateOnly(date).isBefore(today);
          }).toList()..sort(_byScheduledDateThenOrder),
        ),
      ].where((section) => section.tasks.isNotEmpty).toList(),
      _UpcomingView.noDate => [
        _UpcomingTaskSection(
          label: 'No date',
          key: const Key('upcoming-section-no-date'),
          tasks: tasks.where((task) => task.scheduledDate == null).toList()
            ..sort(_byCreatedOrder),
        ),
      ].where((section) => section.tasks.isNotEmpty).toList(),
      _UpcomingView.folders => _folderSections(tasks),
    };
  }

  List<_UpcomingTaskSection> _dateSections(
    Iterable<Task> tasks,
    DateTime today,
    DateTime tomorrow,
  ) {
    final groups = <DateTime, List<Task>>{};

    for (final task in tasks) {
      final scheduledDate = task.scheduledDate;
      if (scheduledDate == null) {
        continue;
      }
      final date = _dateOnly(scheduledDate);
      groups.putIfAbsent(date, () => []).add(task);
    }

    final dates = groups.keys.toList()..sort();
    return [
      for (final date in dates)
        _UpcomingTaskSection(
          label: _sectionLabel(date, today, tomorrow),
          key: Key('upcoming-section-${_sectionKey(date, today, tomorrow)}'),
          tasks: groups[date]!,
        ),
    ];
  }

  List<_UpcomingTaskSection> _folderSections(List<Task> tasks) {
    final groups = <int, List<Task>>{};
    for (final task in tasks) {
      groups.putIfAbsent(task.folderId, () => []).add(task);
    }
    final folderIds = groups.keys.toList()
      ..sort(
        (a, b) => (folderNamesById[a] ?? 'Folder').compareTo(
          folderNamesById[b] ?? 'Folder',
        ),
      );
    return [
      for (final folderId in folderIds)
        _UpcomingTaskSection(
          label: folderNamesById[folderId] ?? 'Folder',
          key: Key(
            'upcoming-section-folder-${_sectionSlug(folderNamesById[folderId] ?? 'folder')}',
          ),
          tasks: groups[folderId]!..sort(_byScheduledDateThenOrder),
        ),
    ];
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _sectionKey(DateTime date, DateTime today, DateTime tomorrow) {
    if (date == today) {
      return 'today';
    }
    if (date == tomorrow) {
      return 'tomorrow';
    }
    return date.toIso8601String();
  }

  String _sectionLabel(DateTime date, DateTime today, DateTime tomorrow) {
    if (date == today) {
      return 'Today';
    }
    if (date == tomorrow) {
      return 'Tomorrow';
    }
    return DateFormat('EEE, MMM d').format(date);
  }

  String _emptyTitleFor(_UpcomingView view) {
    return switch (view) {
      _UpcomingView.agenda => 'Nothing scheduled yet.',
      _UpcomingView.week => 'No tasks this week',
      _UpcomingView.overdue => 'Nothing overdue',
      _UpcomingView.noDate => 'No unscheduled tasks',
      _UpcomingView.folders => 'No active tasks',
    };
  }

  String _emptyMessageFor(_UpcomingView view) {
    return switch (view) {
      _UpcomingView.agenda => "Create a task or add a date when you're ready.",
      _UpcomingView.week => 'Your next seven days are clear.',
      _UpcomingView.overdue => 'Everything scheduled before today is handled.',
      _UpcomingView.noDate => 'Tasks without dates will show up here.',
      _UpcomingView.folders =>
        'Active tasks grouped by folder will show up here.',
    };
  }

  int _byScheduledDateThenOrder(Task a, Task b) {
    final aDate = a.scheduledDate;
    final bDate = b.scheduledDate;
    if (aDate == null && bDate != null) {
      return 1;
    }
    if (aDate != null && bDate == null) {
      return -1;
    }
    if (aDate != null && bDate != null) {
      final byDate = aDate.compareTo(bDate);
      if (byDate != 0) {
        return byDate;
      }
    }
    return _byCreatedOrder(a, b);
  }

  int _byCreatedOrder(Task a, Task b) {
    final bySort = a.globalSortOrder.compareTo(b.globalSortOrder);
    if (bySort != 0) {
      return bySort;
    }
    final byCreated = a.createdAt.compareTo(b.createdAt);
    if (byCreated != 0) {
      return byCreated;
    }
    return a.id.compareTo(b.id);
  }

  String _sectionSlug(String value) {
    final slug = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return slug.isEmpty ? 'folder' : slug;
  }
}

class _UpcomingTaskSection {
  const _UpcomingTaskSection({
    required this.label,
    required this.key,
    required this.tasks,
  });

  final String label;
  final Key key;
  final List<Task> tasks;
}

class _EmptyUpcomingState extends StatelessWidget {
  const _EmptyUpcomingState({
    this.title = 'Nothing scheduled yet.',
    this.message = "Create a task or add a date when you're ready.",
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SyncEmptyState(
      icon: SyncIcons.upcoming,
      title: title,
      message: message,
    );
  }
}

class _UpcomingSectionHeader extends StatelessWidget {
  const _UpcomingSectionHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: colors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.1,
      ),
    );
  }
}

class _UpcomingSectionDivider extends StatelessWidget {
  const _UpcomingSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Divider(height: 1, thickness: 1, color: colors.divider),
    );
  }
}


