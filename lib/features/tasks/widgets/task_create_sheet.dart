import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/services/sync_sounds.dart';
import '../../../shared/sheets/app_bottom_sheet.dart';
import '../providers/folders_provider.dart';

class TaskCreateSheet extends ConsumerStatefulWidget {
  const TaskCreateSheet({
    required this.onSubmit,
    required this.onTodaySelected,
    this.folderLabel = 'Inbox',
    this.initialFolderId,
    super.key,
  });

  final void Function(String title, int? folderId) onSubmit;
  final void Function(String title, int? folderId) onTodaySelected;
  final String folderLabel;
  final int? initialFolderId;

  @override
  ConsumerState<TaskCreateSheet> createState() => _TaskCreateSheetState();
}

class _TaskCreateSheetState extends ConsumerState<TaskCreateSheet> {
  static const _inboxFolderOptionId = -1;

  late final TextEditingController _controller;
  late String _selectedFolderLabel;
  late int? _selectedFolderId;
  var _hasChosenFolder = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _selectedFolderLabel = widget.folderLabel;
    _selectedFolderId = widget.initialFolderId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TaskCreateSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasChosenFolder) {
      return;
    }
    if (oldWidget.initialFolderId != widget.initialFolderId ||
        oldWidget.folderLabel != widget.folderLabel) {
      _selectedFolderId = widget.initialFolderId;
      _selectedFolderLabel = widget.folderLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final folders = ref.watch(foldersProvider).value ?? const [];
    final folderOptions = <int, String>{
      _inboxFolderOptionId: 'Inbox',
      for (final folder in folders.where((folder) => folder.name != 'Inbox'))
        folder.id: folder.name,
    };
    return AppBottomSheet(
      minHeight: 176,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      handleGap: 14,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.15,
              ),
              cursorColor: const Color(0xFF9BCFFF),
              cursorWidth: 3,
              decoration: InputDecoration(
                hintText: 'Task title',
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: _titleBorder(colors),
                enabledBorder: _titleBorder(colors),
                focusedBorder: _titleBorder(colors),
                hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.textSecondary.withValues(alpha: 0.72),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _showFolderPicker(context, folderOptions),
                        style: _chipStyle(context),
                        icon: const Icon(SyncIcons.folder, size: 18),
                        label: Text(_selectedFolderLabel),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          SyncHaptics.selection();
                          SyncSounds.play(SyncSoundEffect.select);
                          widget.onTodaySelected(
                            _controller.text,
                            _selectedFolderId,
                          );
                        },
                        style: _chipStyle(context),
                        icon: const Icon(SyncIcons.date, size: 18),
                        label: const Text('Today'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                label: 'Submit task',
                button: true,
                child: SizedBox.square(
                  dimension: 44,
                  child: IconButton.filled(
                    onPressed: () {
                      SyncHaptics.action();
                      SyncSounds.play(SyncSoundEffect.action);
                      widget.onSubmit(_controller.text, _selectedFolderId);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: colors.controlPrimary,
                      foregroundColor: colors.controlForeground,
                      side: BorderSide.none,
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(SyncIcons.submit, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showFolderPicker(
    BuildContext context,
    Map<int, String> options,
  ) async {
    final colors = SyncTasksColorScheme.of(context);
    SyncHaptics.selection();
    SyncSounds.play(SyncSoundEffect.select);

    if (options.isEmpty) {
      return;
    }

    final selectedId = await showMenu<int>(
      context: context,
      color: colors.surface,
      elevation: 18,
      shadowColor: colors.textPrimary.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.divider),
        borderRadius: BorderRadius.circular(24),
      ),
      constraints: BoxConstraints(
        minWidth: MediaQuery.sizeOf(context).width * 0.64,
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      position: RelativeRect.fromLTRB(
        MediaQuery.sizeOf(context).width * 0.28,
        MediaQuery.sizeOf(context).height * 0.58,
        MediaQuery.sizeOf(context).width * 0.08,
        0,
      ),
      items: [
        for (final option in options.entries)
          PopupMenuItem<int>(
            value: option.key,
            height: 52,
            child: _FolderMenuOptionRow(
              label: option.value,
              selected:
                  option.key == (_selectedFolderId ?? _inboxFolderOptionId),
            ),
          ),
      ],
    );
    if (selectedId == null) {
      return;
    }

    setState(() {
      _hasChosenFolder = true;
      _selectedFolderId = selectedId == _inboxFolderOptionId
          ? null
          : selectedId;
      _selectedFolderLabel = options[selectedId] ?? 'Inbox';
    });
  }

  ButtonStyle _chipStyle(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return OutlinedButton.styleFrom(
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      side: BorderSide(color: colors.divider, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }

  OutlineInputBorder _titleBorder(SyncTasksColorScheme colors) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: colors.divider, width: 1.2),
    );
  }
}

class _FolderMenuOptionRow extends StatelessWidget {
  const _FolderMenuOptionRow({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: selected
              ? Icon(SyncIcons.check, color: colors.textPrimary, size: 22)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
