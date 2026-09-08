import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/widgets/sync_empty_state.dart';
import '../../../shared/widgets/sync_header.dart';
import '../../lists/providers/list_tasks_provider.dart';
import '../../tasks/domain/recurrence_type.dart';
import '../../tasks/domain/task.dart' as domain;
import '../../tasks/providers/folders_provider.dart';
import '../../tasks/providers/task_controller.dart';
import '../../tasks/widgets/task_edit_sheet.dart';
import '../../tasks/widgets/task_metadata.dart';
import '../../tasks/widgets/task_row.dart';
import '../providers/task_search_provider.dart';

class SearchTaskResult {
  const SearchTaskResult({
    required this.id,
    required this.title,
    this.metadata,
  });

  final int id;
  final String title;
  final String? metadata;
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({this.initialTasks = const [], super.key});

  final List<SearchTaskResult> initialTasks;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  var _query = '';
  var _filter = const TaskSearchFilter.all();

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = _query.trim();
    final folders = widget.initialTasks.isEmpty
        ? ref.watch(foldersProvider).value ?? const <Folder>[]
        : const <Folder>[];
    final injectedResults = widget.initialTasks
        .where(
          (task) => task.title.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SyncHeader(title: 'Search'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search tasks'),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            if (widget.initialTasks.isEmpty)
              _SearchFilterBar(
                selectedFilter: _filter,
                folders: folders,
                onSelected: (filter) => setState(() => _filter = filter),
              ),
            Expanded(
              child: widget.initialTasks.isEmpty
                  ? _SearchResults(query: trimmedQuery, filter: _filter)
                  : _InjectedSearchResults(results: injectedResults),
            ),
          ],
        ),
      ),
    );
  }
}

class _InjectedSearchResults extends StatelessWidget {
  const _InjectedSearchResults({required this.results});

  final List<SearchTaskResult> results;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (final task in results)
          TaskRow(
            title: task.title,
            metadata: task.metadata,
            onTap: () {},
            onComplete: () {},
            onDelete: () {},
          ),
      ],
    );
  }
}

class _SearchResults extends ConsumerStatefulWidget {
  const _SearchResults({required this.query, required this.filter});

  final String query;
  final TaskSearchFilter filter;

  @override
  ConsumerState<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<_SearchResults> {
  final _completedOverrides = <int>{};

  @override
  Widget build(BuildContext context) {
    if (widget.query.isEmpty) {
      return const _SearchEmptyState(
        title: 'Search tasks',
        message: 'Type a task title to find it.',
      );
    }

    final folderNamesById = _foldersById(ref.watch(foldersProvider).value);
    final resultsValue = ref.watch(
      taskSearchProvider(
        TaskSearchQuery(query: widget.query, filter: widget.filter),
      ),
    );
    return resultsValue.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return const _SearchEmptyState(
            title: 'No matching tasks',
            message: 'Try a different search term.',
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 108),
          children: [
            for (final task in tasks)
              TaskRow(
                title: task.title,
                metadata: _isCompleted(task)
                    ? 'Completed'
                    : taskMetadataFor(task, folderNamesById: folderNamesById),
                onTap: () => _showEditSheet(context, ref, task),
                onComplete: () => _toggleComplete(ref, task),
                onDelete: () => _deleteTask(ref, task),
                isCompleted: _isCompleted(task),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const _SearchEmptyState(
        title: 'Could not search tasks',
        message: 'Try again in a moment.',
      ),
    );
  }

  Map<int, String> _foldersById(List<Folder>? folders) {
    if (folders == null) {
      return const {};
    }
    return {for (final folder in folders) folder.id: folder.name};
  }

  bool _isCompleted(Task task) {
    return task.isCompleted || _completedOverrides.contains(task.id);
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, Task task) async {
    RecurrenceType? recurrenceType;
    TaskSery? series;
    if (task.seriesId != null) {
      series = await ref
          .read(taskRepositoryProvider)
          .getSeriesForTask(task.seriesId!);
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
            title: task.title,
            scheduledDate: task.scheduledDate,
            scheduledTime: task.scheduledTime,
            reminderTime: task.reminderTime,
            focusDurationMinutes: task.focusDurationMinutes,
            recurrenceType: recurrenceType,
            recurrenceInterval: series?.recurrenceInterval,
            customRepeatLabel: series?.customRepeatLabel,
            onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
            onDone: () => Navigator.of(context, rootNavigator: true).pop(),
            onSave: (update) => _updateTask(ref, task, update),
          ),
        );
      },
    );
  }

  Future<void> _updateTask(
    WidgetRef ref,
    Task task,
    TaskEditUpdate update,
  ) async {
    await ref
        .read(taskControllerProvider)
        .updateTask(
          task.id,
          domain.TaskDraft(
            title: update.title,
            folderId: task.folderId,
            scheduledDate: update.scheduledDate,
            scheduledTime: update.scheduledTime,
            reminderTime: update.reminderTime,
            focusDurationMinutes: update.focusDurationMinutes,
            recurrenceType: update.recurrenceType,
            recurrenceInterval: update.recurrenceInterval,
            customRepeatLabel: update.customRepeatLabel,
          ),
        );
    ref.read(taskSearchRefreshProvider.notifier).bump();
    invalidateTaskListProviders(ref, folderIds: [task.folderId]);
  }

  Future<void> _toggleComplete(WidgetRef ref, Task task) async {
    if (_isCompleted(task)) {
      if (mounted) {
        setState(() => _completedOverrides.remove(task.id));
      }
      await ref
          .read(taskControllerProvider)
          .restore(domain.TaskSnapshot(taskId: task.id));
    } else {
      if (mounted) {
        setState(() => _completedOverrides.add(task.id));
      }
      await ref.read(taskControllerProvider).complete(task.id);
    }
    invalidateTaskListProviders(ref, folderIds: [task.folderId]);
  }

  Future<void> _deleteTask(WidgetRef ref, Task task) async {
    await ref.read(taskControllerProvider).delete(task.id);
    ref.read(taskSearchRefreshProvider.notifier).bump();
    invalidateTaskListProviders(ref, folderIds: [task.folderId]);
  }
}

class _SearchFilterBar extends StatelessWidget {
  const _SearchFilterBar({
    required this.selectedFilter,
    required this.folders,
    required this.onSelected,
  });

  final TaskSearchFilter selectedFilter;
  final List<Folder> folders;
  final ValueChanged<TaskSearchFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        children: [
          _chip('All', const TaskSearchFilter.all()),
          _chip('Today', const TaskSearchFilter.today()),
          _chip('Upcoming', const TaskSearchFilter.upcoming()),
          _chip('Completed', const TaskSearchFilter.completed()),
          for (final folder in folders)
            _chip(folder.name, TaskSearchFilter.folder(folder.id)),
        ],
      ),
    );
  }

  Widget _chip(String label, TaskSearchFilter filter) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedFilter == filter,
        onSelected: (_) => onSelected(filter),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SyncEmptyState(
      icon: SyncIcons.search,
      title: title,
      message: message,
    );
  }
}


