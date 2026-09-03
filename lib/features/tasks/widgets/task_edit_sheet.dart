import 'package:flutter/material.dart';

import '../../../core/theme/synctask_color_scheme.dart';
import '../../../shared/sheets/app_bottom_sheet.dart';
import '../../../shared/widgets/sync_button.dart';
import '../domain/recurrence_type.dart';

class TaskEditUpdate {
  const TaskEditUpdate({
    required this.title,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.reminderTime,
    required this.focusDurationMinutes,
    required this.recurrenceType,
  });

  final String title;
  final DateTime? scheduledDate;
  final DateTime? scheduledTime;
  final DateTime? reminderTime;
  final int? focusDurationMinutes;
  final RecurrenceType? recurrenceType;
}

class TaskEditSheet extends StatefulWidget {
  const TaskEditSheet({
    required this.title,
    required this.onCancel,
    required this.onDone,
    required this.onStartFocus,
    this.focusDurationMinutes,
    this.scheduledDate,
    this.scheduledTime,
    this.reminderTime,
    this.recurrenceType,
    this.onSave,
    this.onStartFocusWithUpdate,
    this.onSaveTitle,
    super.key,
  });

  final String title;
  final int? focusDurationMinutes;
  final DateTime? scheduledDate;
  final DateTime? scheduledTime;
  final DateTime? reminderTime;
  final RecurrenceType? recurrenceType;
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final VoidCallback onStartFocus;
  final Future<void> Function(TaskEditUpdate update)? onSave;
  final Future<void> Function(TaskEditUpdate update)? onStartFocusWithUpdate;
  final Future<void> Function(String title)? onSaveTitle;

  @override
  State<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends State<TaskEditSheet> {
  late final TextEditingController _titleController;
  late DateTime? _scheduledDate;
  late DateTime? _scheduledTime;
  late DateTime? _reminderTime;
  late int? _focusDurationMinutes;
  late RecurrenceType? _recurrenceType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _scheduledDate = widget.scheduledDate;
    _scheduledTime = widget.scheduledTime;
    _reminderTime = widget.reminderTime;
    _focusDurationMinutes = widget.focusDurationMinutes;
    _recurrenceType = widget.recurrenceType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.58,
      minChildSize: 0.42,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        final colors = SyncTaskColorScheme.of(context);
        return AppBottomSheet(
          scrollController: scrollController,
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
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
                      fontWeight: FontWeight.w600,
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
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickDateAction(
                        icon: Icons.wb_sunny_outlined,
                        label: 'Tomorrow',
                        onPressed: () => setState(
                          () => _scheduledDate = _dateOnly(
                            DateTime.now().add(const Duration(days: 1)),
                          ),
                        ),
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: _QuickDateAction(
                        icon: Icons.arrow_forward,
                        label: 'Next Week',
                        onPressed: () => setState(
                          () => _scheduledDate = _dateOnly(
                            DateTime.now().add(const Duration(days: 7)),
                          ),
                        ),
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: _QuickDateAction(
                        icon: Icons.close,
                        label: 'No Date',
                        color: colors.textPrimary,
                        onPressed: () => setState(() {
                          _scheduledDate = null;
                          _scheduledTime = null;
                          _recurrenceType = null;
                        }),
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
                    onTap: _pickDate,
                    trailing: _ValuePill(
                      label: _dateLabel(),
                      showChevron: true,
                    ),
                  ),
                  _SheetRow(
                    icon: Icons.schedule,
                    label: 'Time',
                    trailing: _SheetSwitch(
                      value: _scheduledTime != null,
                      semanticLabel: _scheduledTime == null
                          ? 'Enable task time'
                          : 'Disable task time',
                      onChanged: _toggleTime,
                    ),
                  ),
                  if (_scheduledTime != null)
                    _OptionStrip(
                      label: 'Time options',
                      options: const ['09:00', '13:00', '18:00'],
                      selected: _timeLabel(_scheduledTime),
                      onSelected: _setTimeLabel,
                    ),
                  _SheetRow(
                    icon: Icons.adjust_outlined,
                    label: 'Focus Timer',
                    trailing: _SheetSwitch(
                      value: _focusDurationMinutes != null,
                      semanticLabel: _focusDurationMinutes == null
                          ? 'Enable focus timer'
                          : 'Disable focus timer',
                      onChanged: _toggleFocusTimer,
                    ),
                  ),
                  if (_focusDurationMinutes != null)
                    _OptionStrip(
                      label: 'Focus timer options',
                      options: const ['15 min', '25 min', '45 min'],
                      selected: '$_focusDurationMinutes min',
                      onSelected: _setFocusLabel,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _GroupedRows(
                children: [
                  _SheetRow(
                    icon: Icons.notifications_none,
                    label: 'Reminder',
                    trailing: const _ValuePill(
                      label: 'None',
                      showChevron: true,
                    ),
                  ),
                  _SheetRow(
                    icon: Icons.repeat,
                    label: 'Repeat',
                    trailing: _ValuePill(
                      label: _repeatLabel(_recurrenceType),
                      showChevron: true,
                    ),
                  ),
                  _OptionStrip(
                    label: 'Repeat options',
                    options: const ['None', 'Daily', 'Weekly', 'Monthly'],
                    selected: _repeatLabel(_recurrenceType),
                    onSelected: _setRepeatLabel,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SyncButton.primary(
                label: 'Start Focus',
                height: 52,
                onPressed: _focusDurationMinutes == null
                    ? null
                    : () => _saveAndStartFocus(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleTime(bool enabled) {
    setState(() {
      _scheduledTime = enabled ? _dateWithTime(hour: 9) : null;
    });
  }

  void _toggleFocusTimer(bool enabled) {
    setState(() {
      _focusDurationMinutes = enabled ? 25 : null;
    });
  }

  void _setTimeLabel(String value) {
    final parts = value.split(':');
    setState(() {
      _scheduledTime = _dateWithTime(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    });
  }

  void _setFocusLabel(String value) {
    setState(() {
      _focusDurationMinutes = int.parse(value.split(' ').first);
    });
  }

  void _setRepeatLabel(String value) {
    setState(() {
      _recurrenceType = switch (value) {
        'Daily' => RecurrenceType.daily,
        'Weekly' => RecurrenceType.weekly,
        'Monthly' => RecurrenceType.monthly,
        _ => null,
      };
      if (_recurrenceType != null && _scheduledDate == null) {
        _scheduledDate = _dateOnly(DateTime.now());
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _scheduledDate = _dateOnly(picked));
    }
  }

  DateTime _dateWithTime({required int hour, int minute = 0}) {
    final base = _scheduledDate ?? _dateOnly(DateTime.now());
    _scheduledDate ??= base;
    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String? _timeLabel(DateTime? value) {
    if (value == null) {
      return null;
    }
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  String _repeatLabel(RecurrenceType? type) {
    return switch (type) {
      RecurrenceType.daily => 'Daily',
      RecurrenceType.weekly => 'Weekly',
      RecurrenceType.monthly => 'Monthly',
      null => 'None',
    };
  }

  Future<void> _saveAndClose() async {
    final update = _buildUpdate();
    if (update == null) {
      return;
    }
    await _saveUpdate(update);
    widget.onDone();
  }

  Future<void> _saveAndStartFocus() async {
    final update = _buildUpdate();
    if (update == null) {
      return;
    }
    if (widget.onStartFocusWithUpdate != null) {
      await widget.onStartFocusWithUpdate!(update);
      return;
    }
    await _saveUpdate(update);
    widget.onStartFocus();
  }

  Future<void> _saveUpdate(TaskEditUpdate update) async {
    if (widget.onSave != null) {
      await widget.onSave!(update);
    } else if (update.title != widget.title) {
      await widget.onSaveTitle?.call(update.title);
    }
  }

  TaskEditUpdate? _buildUpdate() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return null;
    }
    return TaskEditUpdate(
      title: title,
      scheduledDate: _scheduledDate,
      scheduledTime: _scheduledTime,
      reminderTime: _reminderTime,
      focusDurationMinutes: _focusDurationMinutes,
      recurrenceType: _recurrenceType,
    );
  }

  String _dateLabel() {
    final scheduledDate = _scheduledDate;
    if (scheduledDate == null) {
      return 'None';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
      ),
    );
  }
}

class _QuickDateAction extends StatelessWidget {
  const _QuickDateAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
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
        borderRadius: BorderRadius.circular(24),
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
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
      ),
    );
  }
}

class _OptionStrip extends StatelessWidget {
  const _OptionStrip({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
                  selected: selected == option,
                  onSelected: (_) => onSelected(option),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected == option
                        ? colors.controlForeground
                        : colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                  selectedColor: colors.controlPrimary,
                  backgroundColor: colors.surfaceSecondary,
                  side: BorderSide(color: colors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
            ],
          ),
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
  const _SheetSwitch({
    required this.value,
    required this.semanticLabel,
    required this.onChanged,
  });

  final bool value;
  final String semanticLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Transform.scale(
      scale: 0.82,
      child: Semantics(
        key: ValueKey(semanticLabel),
        label: semanticLabel,
        button: true,
        toggled: value,
        onTap: () => onChanged(!value),
        child: ExcludeSemantics(
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: colors.textPrimary,
            inactiveThumbColor: colors.surface,
            inactiveTrackColor: colors.textSecondary.withValues(alpha: 0.7),
            trackOutlineColor: WidgetStatePropertyAll(
              colors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
