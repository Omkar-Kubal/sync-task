import 'package:flutter/material.dart';

import '../../../core/theme/synctask_color_scheme.dart';
import '../../../shared/sheets/app_bottom_sheet.dart';
import '../../../shared/widgets/sync_button.dart';

class TaskEditSheet extends StatefulWidget {
  const TaskEditSheet({
    required this.title,
    required this.onCancel,
    required this.onDone,
    required this.onStartFocus,
    this.focusDurationMinutes,
    this.scheduledDate,
    this.onSaveTitle,
    super.key,
  });

  final String title;
  final int? focusDurationMinutes;
  final DateTime? scheduledDate;
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final VoidCallback onStartFocus;
  final Future<void> Function(String title)? onSaveTitle;

  @override
  State<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends State<TaskEditSheet> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.58;
    return AppBottomSheet(
      maxHeight: maxSheetHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              OutlinedButton(
                onPressed: widget.onCancel,
                style: _topActionStyle(context),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              Text(
                'Edit Task',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: _saveAndClose,
                style: _topActionStyle(context),
                child: const Text('Done'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('edit-task-title-field'),
            controller: _titleController,
            textInputAction: TextInputAction.done,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              height: 1.1,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _saveAndClose(),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.divider, width: 1.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _QuickDateAction(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Tomorrow',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _QuickDateAction(
                    icon: Icons.arrow_forward,
                    label: 'Next Week',
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _QuickDateAction(
                    icon: Icons.close,
                    label: 'No Date',
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _GroupedRows(
            children: [
              _SheetRow(
                icon: Icons.calendar_month_outlined,
                label: 'Date',
                trailing: _ValuePill(label: _dateLabel()),
              ),
              _SheetRow(
                icon: Icons.schedule,
                label: 'Time',
                trailing: _SheetSwitch(value: false),
              ),
              _SheetRow(
                icon: Icons.adjust_outlined,
                label: 'Focus Timer',
                trailing: _ValuePill(
                  label: widget.focusDurationMinutes == null
                      ? 'None'
                      : '${widget.focusDurationMinutes} min',
                  showChevron: widget.focusDurationMinutes != null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _GroupedRows(
            children: [
              _SheetRow(
                icon: Icons.notifications_none,
                label: 'Reminder',
                trailing: _ValuePill(label: 'None', showChevron: true),
              ),
              _SheetRow(
                icon: Icons.repeat,
                label: 'Repeat',
                trailing: _ValuePill(label: 'None', showChevron: true),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SyncButton.primary(
            label: 'Start Focus',
            height: 52,
            onPressed: widget.focusDurationMinutes == null
                ? null
                : widget.onStartFocus,
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndClose() async {
    final title = _titleController.text.trim();
    if (title.isNotEmpty && title != widget.title) {
      await widget.onSaveTitle?.call(title);
    }
    widget.onDone();
  }

  String _dateLabel() {
    final scheduledDate = widget.scheduledDate;
    if (scheduledDate == null) {
      return '31 Aug 2026';
    }
    return '${scheduledDate.day} ${_monthLabel(scheduledDate.month)} ${scheduledDate.year}';
  }

  String _monthLabel(int month) {
    return const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }

  ButtonStyle _topActionStyle(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return OutlinedButton.styleFrom(
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      minimumSize: const Size(78, 40),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      side: BorderSide(color: colors.divider, width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    );
  }
}

class _QuickDateAction extends StatelessWidget {
  const _QuickDateAction({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupedRows extends StatelessWidget {
  const _GroupedRows({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.divider, width: 1.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const _HorizontalDivider(),
          ],
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: colors.textPrimary, size: 24),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
          trailing,
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _HorizontalDivider extends StatelessWidget {
  const _HorizontalDivider();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 74, right: 24),
      child: Divider(height: 1, color: colors.divider),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return SizedBox(
      height: 52,
      child: VerticalDivider(color: colors.divider, width: 1),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.label, this.showChevron = false});

  final String label;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: showChevron ? 6 : 12,
        top: 6,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        border: Border.all(color: colors.divider),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
          if (showChevron) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ],
      ),
    );
  }
}

class _SheetSwitch extends StatelessWidget {
  const _SheetSwitch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Transform.scale(
      scale: 0.82,
      child: Switch(
        value: value,
        onChanged: (_) {},
        activeTrackColor: colors.textPrimary,
        inactiveThumbColor: colors.surface,
        inactiveTrackColor: colors.textSecondary.withValues(alpha: 0.7),
        trackOutlineColor: WidgetStatePropertyAll(
          colors.textSecondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
