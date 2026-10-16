import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../core/theme/sync_typography.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/providers/settings_controller.dart';
import '../../lists/providers/list_tasks_provider.dart';
import '../domain/quick_add_parser.dart';
import '../domain/task.dart';
import '../providers/folders_provider.dart';
import '../providers/task_controller.dart';
import '../widgets/task_create_sheet.dart';
import '../widgets/task_edit_sheet.dart';

class QuickAddScreen extends ConsumerStatefulWidget {
  const QuickAddScreen({this.now, super.key});

  final DateTime Function()? now;

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  var _showSuccess = false;
  var _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final defaultFolder = _defaultFolder(settings.defaultFolderId, folders);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {},
                child: TaskCreateSheet(
                  folderLabel: defaultFolder?.name ?? 'Inbox',
                  initialFolderId: defaultFolder?.id,
                  initialScheduledDate: _today(),
                  prepareSchedule: (title, initialScheduledDate) {
                    final parsed = parseQuickAdd(title, now: _now());
                    return TaskCreateScheduleDraft(
                      title: parsed.title,
                      scheduledDate: parsed.hasDateInstruction
                          ? parsed.scheduledDate
                          : initialScheduledDate,
                    );
                  },
                  onSubmit: (title, folderId) async {
                    await _createFromQuickAdd(title, folderId);
                  },
                  onSchedule: _createScheduledFromOptions,
                  onScheduledDone: _showAddedThenClose,
                ),
              ),
            ),
          ),
          if (_showSuccess) const _QuickAddSuccessAffordance(),
        ],
      ),
    );
  }

  Future<void> _createFromQuickAdd(
    String rawTitle,
    int? folderId, {
    DateTime? scheduledDateOverride,
  }) async {
    if (_isSubmitting) {
      return;
    }
    _isSubmitting = true;

    final parsed = scheduledDateOverride == null
        ? parseQuickAdd(rawTitle, now: _now())
        : parseQuickAdd(rawTitle, now: _now()).copyWith(
            scheduledDate: scheduledDateOverride,
            hasDateInstruction: true,
          );
    final title = parsed.title.trim();
    if (title.isNotEmpty) {
      final settings = ref.read(settingsProvider).value ?? const AppSettings();
      final folders = ref.read(foldersProvider).value ?? const <Folder>[];
      final defaultFolder = _defaultFolder(settings.defaultFolderId, folders);
      final taskId = await ref
          .read(taskControllerProvider)
          .create(
            TaskDraft(
              title: title,
              folderId: folderId,
              scheduledDate: parsed.hasDateInstruction
                  ? parsed.scheduledDate
                  : _today(),
            ),
          );
      final task = await ref.read(taskRepositoryProvider).getTask(taskId);
      invalidateTaskListProviders(
        ref,
        folderIds: [
          if (task != null) task.folderId,
          if (folderId != null) folderId,
          if (defaultFolder != null) defaultFolder.id,
        ],
      );
      await _showAddedThenClose();
      return;
    }

    await _close();
  }

  Future<void> _createScheduledFromOptions(
    String title,
    int? folderId,
    TaskEditUpdate update,
  ) async {
    if (_isSubmitting) {
      return;
    }
    _isSubmitting = true;
    final settings = ref.read(settingsProvider).value ?? const AppSettings();
    final folders = ref.read(foldersProvider).value ?? const <Folder>[];
    final defaultFolder = _defaultFolder(settings.defaultFolderId, folders);
    final taskId = await ref
        .read(taskControllerProvider)
        .create(
          TaskDraft(
            title: update.title.trim(),
            folderId: folderId,
            scheduledDate: update.scheduledDate,
            scheduledTime: update.scheduledTime,
            reminderTime: update.reminderTime,
            focusDurationMinutes: update.focusDurationMinutes,
            recurrenceType: update.recurrenceType,
            recurrenceInterval: update.recurrenceInterval,
            customRepeatLabel: update.customRepeatLabel,
          ),
        );
    final task = await ref.read(taskRepositoryProvider).getTask(taskId);
    invalidateTaskListProviders(
      ref,
      folderIds: [
        if (task != null) task.folderId,
        if (folderId != null) folderId,
        if (defaultFolder != null) defaultFolder.id,
      ],
    );
  }

  Future<void> _showAddedThenClose() async {
    if (!mounted) {
      return;
    }
    setState(() => _showSuccess = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    await _close();
  }

  Future<void> _close() {
    return SystemNavigator.pop();
  }

  Folder? _defaultFolder(int? folderId, List<Folder> folders) {
    if (folderId == null) {
      return null;
    }
    for (final folder in folders) {
      if (folder.id == folderId) {
        return folder;
      }
    }
    return null;
  }

  DateTime _now() => widget.now?.call() ?? DateTime.now();

  DateTime _today() {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }
}

class _QuickAddSuccessAffordance extends StatelessWidget {
  const _QuickAddSuccessAffordance();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 196,
      child: IgnorePointer(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.controlPrimary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Added',
                style: SyncTypography.of(
                  context,
                ).button.copyWith(color: colors.controlForeground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
