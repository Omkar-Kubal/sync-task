import '../../../shared/icons/list_filter_icon.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../receipts/providers/receipt_feature_provider.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_fab.dart';
import '../../tasks/domain/task.dart' as domain;
import '../../tasks/providers/folders_provider.dart';
import '../../tasks/providers/task_controller.dart';
import '../../tasks/widgets/task_create_sheet.dart';
import '../../tasks/widgets/task_edit_sheet.dart';
import 'list_detail_screen.dart';
import '../providers/list_summary_provider.dart';
import '../providers/list_tasks_provider.dart';

typedef _ListSheetBuilder =
    Widget Function(BuildContext context, ScrollController scrollController);

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final summaryValue = ref.watch(listSummaryProvider);
    final foldersValue = ref.watch(foldersProvider);
    final receiptFeatureEnabled = ref.watch(receiptFeatureEnabledProvider);

    final summary = summaryValue.value;
    final folders = foldersValue.value;

    return Scaffold(
      backgroundColor: colors.scaffold,
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
                        'Lists',
                        style: textTheme.displaySmall?.copyWith(
                          color: colors.textPrimary,
                          fontSize: 29,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 108),
                children: [
                  const _SectionLabel('Organisation hub'),
                  const SizedBox(height: 8),
                  _ListCard(
                    key: const Key('lists-primary-section'),
                    children: [
                      _ListRow(
                        label: 'All',
                        semanticLabel: 'Open All list',
                        icon: const ListFilterIcon(size: 20, strokeWidth: 1.6),
                        count: summary?.allCount,
                        onTap: () => _showListSheet(
                          context,
                          (sheetContext, scrollController) => AllTasksScreen(
                            onClose: () => Navigator.of(
                              sheetContext,
                              rootNavigator: true,
                            ).pop(),
                            scrollController: scrollController,
                          ),
                        ),
                      ),
                      _ListRow(
                        key: const Key('lists-today-shortcut-row'),
                        label: 'Today',
                        semanticLabel: 'Open Today list',
                        icon: const _DateIcon(),
                        count: summary?.todayCount,
                        onTap: () => context.push('/today'),
                      ),
                      _ListRow(
                        key: const Key('lists-upcoming-shortcut-row'),
                        label: 'Upcoming',
                        semanticLabel: 'Open Upcoming list',
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendar04,
                          size: 20,
                          color: colors.textPrimary,
                          strokeWidth: 1.5,
                        ),
                        count: summary?.upcomingCount,
                        onTap: () => context.push('/upcoming'),
                      ),
                      _ListRow(
                        label: 'Completed',
                        semanticLabel: 'Open Completed list',
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedBookCheck,
                          size: 20,
                          color: colors.textPrimary,
                          strokeWidth: 1.5,
                        ),
                        count: summary?.completedCount,
                        onTap: () => _showListSheet(
                          context,
                          (sheetContext, scrollController) =>
                              CompletedTasksScreen(
                                onClose: () => Navigator.of(
                                  sheetContext,
                                  rootNavigator: true,
                                ).pop(),
                                scrollController: scrollController,
                              ),
                        ),
                      ),
                      if (receiptFeatureEnabled)
                        _ListRow(
                          label: 'Receipts',
                          semanticLabel: 'Open Receipts',
                          icon: Icon(
                            SyncIcons.receipt,
                            size: 20,
                            color: colors.textPrimary,
                          ),
                          onTap: () => context.go('/receipts'),
                        ),
                      _ListRow(
                        label: 'Insights',
                        semanticLabel: 'Open Insights',
                        icon: Icon(
                          SyncIcons.insights,
                          size: 20,
                          color: colors.textPrimary,
                        ),
                        onTap: () => context.go('/lists/insights'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SectionLabel(
                    'MY FOLDERS',
                    onAddPressed: () => _showCreateFolderDialog(context, ref),
                  ),
                  const SizedBox(height: 8),
                  _ListCard(
                    key: const Key('lists-inbox-section'),
                    children: [
                      _ListRow(
                        label: 'Inbox',
                        semanticLabel: 'Open Inbox list',
                        icon: const Icon(SyncIcons.folder),
                        count: summary?.inboxCount,
                        onTap: () => _showListSheet(
                          context,
                          (sheetContext, scrollController) => InboxTasksScreen(
                            onClose: () => Navigator.of(
                              sheetContext,
                              rootNavigator: true,
                            ).pop(),
                            scrollController: scrollController,
                          ),
                        ),
                      ),
                      if (folders != null)
                        for (final folder in folders.where(
                          (folder) => folder.name != 'Inbox',
                        ))
                          _ListRow(
                            label: folder.name,
                            semanticLabel: 'Open ${folder.name} list',
                            icon: const Icon(SyncIcons.folder),
                            count: summary?.folderCounts[folder.id],
                            onTap: () => _showListSheet(
                              context,
                              (sheetContext, scrollController) =>
                                  FolderTasksScreen(
                                    folderId: folder.id,
                                    onClose: () => Navigator.of(
                                      sheetContext,
                                      rootNavigator: true,
                                    ).pop(),
                                    scrollController: scrollController,
                                  ),
                            ),
                            onDelete: () => _deleteFolder(
                              context,
                              ref,
                              folder.id,
                              folder.name,
                            ),
                          ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel('REMINDERS'),
                  const SizedBox(height: 8),
                  _ListCard(
                    key: const Key('lists-reminders-section'),
                    children: [
                      _ListRow(
                        label: 'Reminders',
                        semanticLabel: 'Open Reminders list',
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedNotification03,
                          size: 20,
                          color: colors.textPrimary,
                          strokeWidth: 1.5,
                        ),
                        count: summary?.remindersCount,
                        onTap: () => _showListSheet(
                          context,
                          (sheetContext, scrollController) => RemindersScreen(
                            onClose: () => Navigator.of(
                              sheetContext,
                              rootNavigator: true,
                            ).pop(),
                            scrollController: scrollController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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

  void _showListSheet(BuildContext context, _ListSheetBuilder builder) {
    final colors = SyncTasksColorScheme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.52,
          minChildSize: 0.42,
          maxChildSize: 0.94,
          snap: true,
          snapSizes: const [0.52, 0.94],
          builder: (sheetContext, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: ColoredBox(
                color: colors.scaffold,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.textSecondary.withValues(alpha: 0.38),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(child: builder(sheetContext, scrollController)),
                  ],
                ),
              ),
            );
          },
        );
      },
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
            onSubmit: (title, folderId) =>
                unawaited(_createTask(sheetContext, ref, title, folderId)),
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
    required String initialTitle,
    DateTime? initialScheduledDate,
  }) {
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
            title: initialTitle,
            scheduledDate: initialScheduledDate,
            onCancel: () => Navigator.of(sheetContext).pop(),
            onDone: () => Navigator.of(sheetContext).pop(),
            onSave: (update) => _createTaskFromUpdate(ref, update),
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
        .create(domain.TaskDraft(title: trimmedTitle, folderId: folderId));
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

  Future<void> _showCreateFolderDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final created = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final colors = SyncTasksColorScheme.of(dialogContext);
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'New Folder',
            style: Theme.of(
              dialogContext,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Folder name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (created != null && created.isNotEmpty) {
      await ref.read(folderRepositoryProvider).createFolder(created);
      ref.invalidate(foldersProvider);
      ref.invalidate(listSummaryProvider);
    }
  }

  Future<void> _deleteFolder(
    BuildContext context,
    WidgetRef ref,
    int folderId,
    String folderName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = SyncTasksColorScheme.of(dialogContext);
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Delete $folderName?'),
          content: const Text('Tasks in this folder will be moved to Inbox.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: colors.destructive),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(folderRepositoryProvider).deleteFolder(folderId);
      ref.invalidate(foldersProvider);
      ref.invalidate(listSummaryProvider);
    }
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 54, right: 16),
                  child: Divider(height: 1, color: colors.divider),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
    this.count,
    this.onDelete,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final Widget icon;
  final int? count;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Semantics(
      container: true,
      button: true,
      onTap: onTap,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: () {
            SyncHaptics.selection();
            onTap();
          },
          onLongPress: onDelete == null
              ? null
              : () {
                  SyncHaptics.selection();
                  onDelete!();
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 22,
                    child: IconTheme(
                      data: IconThemeData(color: colors.textPrimary, size: 20),
                      child: Center(child: icon),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (count != null && count! > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    SyncIcons.chevron,
                    color: colors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateIcon extends StatelessWidget {
  const _DateIcon();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final today = DateTime.now().day.toString();
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colors.textPrimary, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        today,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {this.onAddPressed});

  final String label;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          if (onAddPressed != null) ...[
            const Spacer(),
            InkWell(
              onTap: () {
                SyncHaptics.selection();
                onAddPressed!();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Icon(
                  Icons.add_rounded,
                  color: colors.textSecondary,
                  size: 22,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
