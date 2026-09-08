import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';

import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/sheets/app_bottom_sheet.dart';
import '../domain/recurrence_type.dart';

class TaskEditUpdate {
  const TaskEditUpdate({
    required this.title,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.reminderTime,
    required this.focusDurationMinutes,
    required this.recurrenceType,
    this.recurrenceInterval,
    this.customRepeatLabel,
  });

  final String title;
  final DateTime? scheduledDate;
  final DateTime? scheduledTime;
  final DateTime? reminderTime;
  final int? focusDurationMinutes;
  final RecurrenceType? recurrenceType;
  final int? recurrenceInterval;
  final String? customRepeatLabel;
}

class TaskEditSheet extends StatefulWidget {
  const TaskEditSheet({
    required this.title,
    required this.onCancel,
    required this.onDone,
    this.focusDurationMinutes,
    this.scheduledDate,
    this.scheduledTime,
    this.reminderTime,
    this.recurrenceType,
    this.recurrenceInterval,
    this.customRepeatLabel,
    this.onSave,
    this.onSaveTitle,
    super.key,
  });

  final String title;
  final int? focusDurationMinutes;
  final DateTime? scheduledDate;
  final DateTime? scheduledTime;
  final DateTime? reminderTime;
  final RecurrenceType? recurrenceType;
  final int? recurrenceInterval;
  final String? customRepeatLabel;
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final Future<void> Function(TaskEditUpdate update)? onSave;
  final Future<void> Function(String title)? onSaveTitle;

  @override
  State<TaskEditSheet> createState() => _TaskEditSheetState();
}

class _TaskEditSheetState extends State<TaskEditSheet> {
  late final TextEditingController _titleController;
  late DateTime? _scheduledDate;
  late DateTime? _scheduledTime;
  late DateTime? _reminderTime;
  late int? _durationMinutes;
  late RecurrenceType? _recurrenceType;
  late _ReminderPreset _reminderPreset;
  var _customRepeatSelected = false;
  String? _customRepeatLabel;
  int? _customRepeatInterval;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _scheduledDate = widget.scheduledDate;
    _scheduledTime = widget.scheduledTime;
    _reminderTime = widget.reminderTime;
    _durationMinutes = widget.focusDurationMinutes;
    _recurrenceType = widget.recurrenceType;
    _customRepeatInterval = widget.recurrenceInterval ?? 1;
    _customRepeatLabel = widget.customRepeatLabel;
    _customRepeatSelected =
        widget.customRepeatLabel != null ||
        (widget.recurrenceInterval != null && widget.recurrenceInterval! > 1);
    _reminderPreset = _inferReminderPreset();
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
      initialChildSize: 0.50,
      minChildSize: 0.34,
      maxChildSize: 0.86,
      builder: (context, scrollController) {
        final colors = SyncTasksColorScheme.of(context);
        final sheetHeight = (MediaQuery.sizeOf(context).height * 0.50).clamp(
          320.0,
          420.0,
        );
        return AppBottomSheet(
          scrollController: scrollController,
          minHeight: sheetHeight,
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          handleGap: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 76,
                    child: OutlinedButton(
                      onPressed: () {
                        SyncHaptics.selection();
                        widget.onCancel();
                      },
                      style: _topActionStyle(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Edit Task',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 76,
                    child: OutlinedButton(
                      key: const Key('edit-task-done-button'),
                      onPressed: () {
                        SyncHaptics.action();
                        _saveAndClose();
                      },
                      style: _topActionStyle(context),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('edit-task-title-field'),
                controller: _titleController,
                textInputAction: TextInputAction.done,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 20,
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
                onSubmitted: (_) {
                  SyncHaptics.action();
                  _saveAndClose();
                },
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickDateAction(
                        icon: SyncIcons.tomorrow,
                        label: 'Tomorrow',
                        onPressed: () => _saveQuickDate(
                          _dateOnly(
                            DateTime.now().add(const Duration(days: 1)),
                          ),
                        ),
                      ),
                    ),
                    const _VerticalDivider(),
                    Expanded(
                      child: _QuickDateAction(
                        icon: SyncIcons.nextWeek,
                        label: 'Next Week',
                        onPressed: () => _saveQuickDate(
                          _dateOnly(
                            DateTime.now().add(const Duration(days: 7)),
                          ),
                        ),
                      ),
                    ),
                    const _VerticalDivider(),
                    Expanded(
                      child: _QuickDateAction(
                        icon: SyncIcons.noDate,
                        label: 'No Date',
                        color: colors.destructive,
                        onPressed: () => _saveQuickDate(null),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _GroupedRows(
                children: [
                  _SheetRow(
                    icon: SyncIcons.date,
                    label: 'Date',
                    onTap: _pickDate,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ValuePill(label: _dateLabel(), onTap: _pickDate),
                        if (_scheduledTime != null) ...[
                          const SizedBox(width: 8),
                          _ValuePill(
                            label: _timeLabel(_scheduledTime!)!,
                            onTap: _pickTime,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _SheetRow(
                    icon: SyncIcons.time,
                    label: 'Time',
                    trailing: _SheetSwitch(
                      value: _scheduledTime != null,
                      semanticLabel: _scheduledTime == null
                          ? 'Enable task time'
                          : 'Disable task time',
                      onChanged: _toggleTime,
                    ),
                  ),
                  _SheetRow(
                    icon: SyncIcons.duration,
                    label: 'Duration',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_durationMinutes != null) ...[
                          _ValuePill(
                            label: _durationLabel(),
                            onTap: _showDurationMenu,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _SheetSwitch(
                          value: _durationMinutes != null,
                          semanticLabel: _durationMinutes == null
                              ? 'Enable task duration'
                              : 'Disable task duration',
                          onChanged: _toggleDuration,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _GroupedRows(
                children: [
                  _SheetRow(
                    icon: SyncIcons.reminder,
                    label: 'Reminder',
                    onTap: _showReminderMenu,
                    trailing: _PlainValueTrailing(
                      label: _reminderLabel(),
                      showClear: _reminderPreset != _ReminderPreset.none,
                      onClear: _clearReminder,
                    ),
                  ),
                  _SheetRow(
                    icon: SyncIcons.repeat,
                    label: 'Repeat',
                    onTap: _showRepeatMenu,
                    trailing: _PlainValueTrailing(
                      label: _repeatLabel(),
                      showChevron: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveQuickDate(DateTime? date) async {
    setState(() {
      _scheduledDate = date;
      if (date == null) {
        _scheduledTime = null;
        _reminderTime = null;
        _reminderPreset = _ReminderPreset.none;
        _recurrenceType = null;
        _customRepeatSelected = false;
      } else if (_reminderTime != null) {
        _reminderTime = DateTime(
          date.year,
          date.month,
          date.day,
          _reminderTime!.hour,
          _reminderTime!.minute,
        );
      }
    });
    await _saveAndClose();
  }

  void _toggleTime(bool enabled) {
    setState(() {
      _scheduledTime = enabled ? _dateWithTime(hour: 0) : null;
      if (!enabled) {
        _reminderTime = null;
        _reminderPreset = _ReminderPreset.none;
      }
    });
  }

  void _toggleDuration(bool enabled) {
    setState(() {
      _durationMinutes = enabled ? (_durationMinutes ?? 30) : null;
    });
  }

  Future<void> _showReminderMenu() async {
    final selected = await _showFloatingMenu<_ReminderPreset>(
      items: [
        _MenuChoice(
          value: _ReminderPreset.none,
          label: 'None',
          selected: _reminderPreset == _ReminderPreset.none,
        ),
        _MenuChoice(
          value: _ReminderPreset.onTime,
          label: 'On time',
          selected: _reminderPreset == _ReminderPreset.onTime,
        ),
        _MenuChoice(
          value: _ReminderPreset.fifteenMinutesBefore,
          label: '15 minutes before',
          selected: _reminderPreset == _ReminderPreset.fifteenMinutesBefore,
        ),
        _MenuChoice(
          value: _ReminderPreset.oneHourBefore,
          label: '1 hour before',
          selected: _reminderPreset == _ReminderPreset.oneHourBefore,
        ),
        _MenuChoice(
          value: _ReminderPreset.oneDayBefore,
          label: '1 day before (00:00)',
          selected: _reminderPreset == _ReminderPreset.oneDayBefore,
        ),
        _MenuChoice(
          value: _ReminderPreset.oneWeekBefore,
          label: '1 week before (00:00)',
          selected: _reminderPreset == _ReminderPreset.oneWeekBefore,
        ),
        _MenuChoice(
          value: _ReminderPreset.custom,
          label: 'Custom',
          selected: _reminderPreset == _ReminderPreset.custom,
          showChevron: true,
        ),
      ],
    );
    if (selected == null) {
      return;
    }
    if (selected == _ReminderPreset.custom) {
      await _openCustomReminderSheet();
      return;
    }
    _applyReminderPreset(selected);
  }

  Future<void> _showRepeatMenu() async {
    final selected = await _showFloatingMenu<String>(
      items: [
        _MenuChoice(
          value: 'none',
          label: 'None',
          selected: _repeatLabel() == 'None',
        ),
        _MenuChoice(
          value: 'daily',
          label: 'Daily',
          selected:
              !_customRepeatSelected && _recurrenceType == RecurrenceType.daily,
        ),
        _MenuChoice(
          value: 'weekly',
          label: 'Weekly',
          selected:
              !_customRepeatSelected &&
              _recurrenceType == RecurrenceType.weekly,
        ),
        _MenuChoice(
          value: 'monthly',
          label: 'Monthly',
          selected:
              !_customRepeatSelected &&
              _recurrenceType == RecurrenceType.monthly,
        ),
        _MenuChoice(
          value: 'custom',
          label: 'Custom',
          selected: _customRepeatSelected,
          showChevron: true,
        ),
      ],
    );
    if (selected == null) {
      return;
    }
    if (selected == 'custom') {
      await _openCustomRepeatSheet();
      return;
    }
    _setRepeatValue(selected);
  }

  Future<void> _showDurationMenu() async {
    final selected = await _showFloatingMenu<int>(
      items: [
        _MenuChoice(
          value: 15,
          label: '15 min',
          selected: _durationMinutes == 15,
        ),
        _MenuChoice(
          value: 30,
          label: '30 min',
          selected: _durationMinutes == 30,
        ),
        _MenuChoice(
          value: 45,
          label: '45 min',
          selected: _durationMinutes == 45,
        ),
        _MenuChoice(
          value: 60,
          label: '1 hour',
          selected: _durationMinutes == 60,
        ),
        _MenuChoice(
          value: 90,
          label: '1 hr 30 min',
          selected: _durationMinutes == 90,
        ),
        _MenuChoice(
          value: 120,
          label: '2 hours',
          selected: _durationMinutes == 120,
        ),
      ],
    );
    if (selected != null) {
      setState(() => _durationMinutes = selected);
    }
  }

  Future<T?> _showFloatingMenu<T>({required List<_MenuChoice<T>> items}) {
    final colors = SyncTasksColorScheme.of(context);
    final size = MediaQuery.sizeOf(context);
    return showMenu<T>(
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
        minWidth: size.width * 0.64,
        maxWidth: size.width * 0.72,
      ),
      position: RelativeRect.fromLTRB(
        size.width * 0.28,
        size.height * 0.36,
        size.width * 0.08,
        0,
      ),
      items: [
        for (final item in items)
          PopupMenuItem<T>(
            value: item.value,
            height: 52,
            child: _MenuOptionRow(
              label: item.label,
              selected: item.selected,
              showChevron: item.showChevron,
            ),
          ),
      ],
    );
  }

  void _applyReminderPreset(_ReminderPreset preset) {
    setState(() {
      _reminderPreset = preset;
      if (preset == _ReminderPreset.none) {
        _reminderTime = null;
        return;
      }
      _scheduledDate ??= _dateOnly(DateTime.now());
      _reminderTime = _reminderTimeForPreset(preset);
    });
  }

  Future<void> _openCustomReminderSheet() async {
    final baseDate = _scheduledDate ?? _dateOnly(DateTime.now());
    final initialTime = _scheduledTime == null
        ? TimeOfDay.fromDateTime(DateTime.now())
        : TimeOfDay.fromDateTime(_scheduledTime!);
    final picked = await showModalBottomSheet<DateTime>(
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
          child: _CustomReminderSheet(
            baseDate: baseDate,
            initialTime: initialTime,
          ),
        );
      },
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _scheduledDate ??= baseDate;
      _reminderTime = picked;
      _reminderPreset = _ReminderPreset.custom;
    });
  }

  void _clearReminder() {
    SyncHaptics.selection();
    setState(() {
      _reminderTime = null;
      _reminderPreset = _ReminderPreset.none;
    });
  }

  void _setRepeatValue(String value) {
    setState(() {
      _customRepeatSelected = false;
      _customRepeatLabel = null;
      _recurrenceType = switch (value) {
        'daily' => RecurrenceType.daily,
        'weekly' => RecurrenceType.weekly,
        'monthly' => RecurrenceType.monthly,
        _ => null,
      };
      if (_recurrenceType != null && _scheduledDate == null) {
        _scheduledDate = _dateOnly(DateTime.now());
      }
    });
  }

  Future<void> _openCustomRepeatSheet() async {
    final result = await showModalBottomSheet<_CustomRepeatResult>(
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
          child: _CustomRepeatSheet(
            initialInterval: 1,
            initialUnit: _recurrenceType == RecurrenceType.monthly
                ? _RepeatUnit.month
                : (_recurrenceType == RecurrenceType.weekly
                      ? _RepeatUnit.week
                      : _RepeatUnit.day),
          ),
        );
      },
    );
    if (result == null) {
      return;
    }
    setState(() {
      _customRepeatSelected = true;
      _recurrenceType = result.recurrenceType;
      _customRepeatLabel = result.label;
      _scheduledDate ??= _dateOnly(DateTime.now());
    });
  }

  void _setScheduledDate(DateTime date) {
    setState(() {
      _scheduledDate = date;
      if (_scheduledTime != null) {
        _scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          _scheduledTime!.hour,
          _scheduledTime!.minute,
        );
      }
      if (_reminderTime != null) {
        _reminderTime = DateTime(
          date.year,
          date.month,
          date.day,
          _reminderTime!.hour,
          _reminderTime!.minute,
        );
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
      _setScheduledDate(_dateOnly(picked));
    }
  }

  Future<void> _pickTime() async {
    final initial = _scheduledTime ?? _dateWithTime(hour: 0, minute: 0);
    final colors = SyncTasksColorScheme.of(context);
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 270,
              height: 200,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: cupertino.CupertinoDatePicker(
                mode: cupertino.CupertinoDatePickerMode.time,
                initialDateTime: initial,
                use24hFormat: false,
                onDateTimeChanged: (DateTime newDateTime) {
                  SyncHaptics.selection();
                  setState(() {
                    _scheduledTime = _dateWithTime(
                      hour: newDateTime.hour,
                      minute: newDateTime.minute,
                    );
                    if (_reminderPreset != _ReminderPreset.none &&
                        _reminderPreset != _ReminderPreset.custom) {
                      _reminderTime = _reminderTimeForPreset(_reminderPreset);
                    }
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  DateTime _dateWithTime({required int hour, int minute = 0}) {
    final base = _scheduledDate ?? _dateOnly(DateTime.now());
    _scheduledDate ??= base;
    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  DateTime _eventDateTime() {
    final base = _scheduledDate ?? _dateOnly(DateTime.now());
    final time = _scheduledTime;
    return DateTime(
      base.year,
      base.month,
      base.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
  }

  DateTime _reminderTimeForPreset(_ReminderPreset preset) {
    final event = _eventDateTime();
    final dateOnly = DateTime(event.year, event.month, event.day);
    return switch (preset) {
      _ReminderPreset.onTime => event,
      _ReminderPreset.fifteenMinutesBefore => event.subtract(
        const Duration(minutes: 15),
      ),
      _ReminderPreset.oneHourBefore => event.subtract(const Duration(hours: 1)),
      _ReminderPreset.oneDayBefore => dateOnly.subtract(
        const Duration(days: 1),
      ),
      _ReminderPreset.oneWeekBefore => dateOnly.subtract(
        const Duration(days: 7),
      ),
      _ReminderPreset.none || _ReminderPreset.custom => event,
    };
  }

  _ReminderPreset _inferReminderPreset() {
    final reminder = _reminderTime;
    if (reminder == null) {
      return _ReminderPreset.none;
    }
    final event = _eventDateTime();
    final dateOnly = DateTime(event.year, event.month, event.day);
    if (reminder == event) {
      return _ReminderPreset.onTime;
    }
    if (reminder == event.subtract(const Duration(minutes: 15))) {
      return _ReminderPreset.fifteenMinutesBefore;
    }
    if (reminder == event.subtract(const Duration(hours: 1))) {
      return _ReminderPreset.oneHourBefore;
    }
    if (reminder == dateOnly.subtract(const Duration(days: 1))) {
      return _ReminderPreset.oneDayBefore;
    }
    if (reminder == dateOnly.subtract(const Duration(days: 7))) {
      return _ReminderPreset.oneWeekBefore;
    }
    return _ReminderPreset.custom;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String? _timeLabel(DateTime? value) {
    if (value == null) {
      return null;
    }
    return _timeOfDayLabel(TimeOfDay(hour: value.hour, minute: value.minute));
  }

  String _timeOfDayLabel(TimeOfDay value) {
    final period = value.hour < 12 ? 'AM' : 'PM';
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    return '$hour:${value.minute.toString().padLeft(2, '0')} $period';
  }

  String _durationLabel() {
    final minutes = _durationMinutes ?? 0;
    if (minutes >= 60 && minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return hours == 1 ? '1 hr' : '$hours hrs';
    }
    return '$minutes min';
  }

  String _reminderLabel() {
    return switch (_reminderPreset) {
      _ReminderPreset.none => 'None',
      _ReminderPreset.onTime => 'On time',
      _ReminderPreset.fifteenMinutesBefore => '15 min before',
      _ReminderPreset.oneHourBefore => '1 hour before',
      _ReminderPreset.oneDayBefore => '1 day before',
      _ReminderPreset.oneWeekBefore => '1 week before',
      _ReminderPreset.custom => 'Custom',
    };
  }

  String _repeatLabel() {
    if (_customRepeatSelected && _customRepeatLabel != null) {
      return _customRepeatLabel!;
    }
    if (_customRepeatSelected) {
      return 'Custom';
    }
    return switch (_recurrenceType) {
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
      focusDurationMinutes: _durationMinutes,
      recurrenceType: _recurrenceType,
      recurrenceInterval: _customRepeatSelected
          ? (_customRepeatInterval ?? 1)
          : 1,
      customRepeatLabel: _customRepeatSelected ? _customRepeatLabel : null,
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
    final colors = SyncTasksColorScheme.of(context);
    return OutlinedButton.styleFrom(
      backgroundColor: colors.surfaceSecondary,
      foregroundColor: colors.textPrimary,
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}

enum _ReminderPreset {
  none,
  onTime,
  fifteenMinutesBefore,
  oneHourBefore,
  oneDayBefore,
  oneWeekBefore,
  custom,
}

enum _ReminderUnit { day, week, month }

class _MenuChoice<T> {
  const _MenuChoice({
    required this.value,
    required this.label,
    required this.selected,
    this.showChevron = false,
  });

  final T value;
  final String label;
  final bool selected;
  final bool showChevron;
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
      onTap: () {
        SyncHaptics.selection();
        onPressed();
      },
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
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
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
    final colors = SyncTasksColorScheme.of(context);
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              SyncHaptics.selection();
              onTap!();
            },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: colors.textPrimary, size: 24),
              const SizedBox(width: 14),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOptionRow extends StatelessWidget {
  const _MenuOptionRow({
    required this.label,
    required this.selected,
    this.showChevron = false,
  });

  final String label;
  final bool selected;
  final bool showChevron;

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
        if (showChevron)
          Icon(SyncIcons.chevron, color: colors.textPrimary, size: 24),
      ],
    );
  }
}

class _HorizontalDivider extends StatelessWidget {
  const _HorizontalDivider();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
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
    final colors = SyncTasksColorScheme.of(context);
    return SizedBox(
      height: 72,
      child: VerticalDivider(color: colors.divider, width: 1),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
    );

    if (onTap == null) {
      return pill;
    }
    return InkWell(
      onTap: () {
        SyncHaptics.selection();
        onTap!();
      },
      borderRadius: BorderRadius.circular(18),
      child: pill,
    );
  }
}

class _PlainValueTrailing extends StatelessWidget {
  const _PlainValueTrailing({
    required this.label,
    this.showClear = false,
    this.showChevron = false,
    this.onClear,
  });

  final String label;
  final bool showClear;
  final bool showChevron;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        if (showClear) ...[
          const SizedBox(width: 10),
          InkResponse(
            onTap: onClear,
            radius: 18,
            child: Icon(SyncIcons.close, color: colors.textSecondary, size: 22),
          ),
        ],
        if (showChevron) ...[
          const SizedBox(width: 8),
          Icon(SyncIcons.dropdown, color: colors.textSecondary, size: 22),
        ],
      ],
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
    final colors = SyncTasksColorScheme.of(context);
    void handleChanged(bool nextValue) {
      SyncHaptics.selection();
      onChanged(nextValue);
    }

    return Transform.scale(
      scale: 0.82,
      child: Semantics(
        key: ValueKey(semanticLabel),
        label: semanticLabel,
        button: true,
        toggled: value,
        onTap: () => handleChanged(!value),
        child: ExcludeSemantics(
          child: Switch(
            value: value,
            onChanged: handleChanged,
            activeTrackColor: const Color(0xFF34C759),
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

class _CustomReminderSheet extends StatefulWidget {
  const _CustomReminderSheet({
    required this.baseDate,
    required this.initialTime,
  });

  final DateTime baseDate;
  final TimeOfDay initialTime;

  @override
  State<_CustomReminderSheet> createState() => _CustomReminderSheetState();
}

class _CustomReminderSheetState extends State<_CustomReminderSheet> {
  late final cupertino.FixedExtentScrollController _amountController;
  late final cupertino.FixedExtentScrollController _unitController;
  late TimeOfDay _time;
  var _amount = 1;
  var _unit = _ReminderUnit.day;

  @override
  void initState() {
    super.initState();
    _amountController = cupertino.FixedExtentScrollController(initialItem: 1);
    _unitController = cupertino.FixedExtentScrollController();
    _time = widget.initialTime;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.62;
    return AppBottomSheet(
      minHeight: maxSheetHeight < 430 ? maxSheetHeight : 430,
      maxHeight: maxSheetHeight,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
      handleGap: 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 76,
                child: OutlinedButton(
                  onPressed: () {
                    SyncHaptics.selection();
                    Navigator.of(context).pop();
                  },
                  style: _sheetTopActionStyle(context),
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Custom Reminder',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 76,
                child: OutlinedButton(
                  key: const Key('custom-reminder-done-button'),
                  onPressed: () {
                    SyncHaptics.action();
                    Navigator.of(context).pop(_reminderDateTime());
                  },
                  style: _sheetTopActionStyle(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 136,
                  child: Row(
                    children: [
                      Expanded(
                        child: cupertino.CupertinoPicker(
                          scrollController: _amountController,
                          itemExtent: 42,
                          magnification: 1.02,
                          squeeze: 1.08,
                          selectionOverlay:
                              const cupertino.CupertinoPickerDefaultSelectionOverlay(),
                          onSelectedItemChanged: (index) {
                            SyncHaptics.selection();
                            setState(() => _amount = index);
                          },
                          children: [
                            for (var value = 0; value <= 30; value++)
                              Center(child: Text('$value')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: cupertino.CupertinoPicker(
                          scrollController: _unitController,
                          itemExtent: 42,
                          magnification: 1.02,
                          squeeze: 1.08,
                          selectionOverlay:
                              const cupertino.CupertinoPickerDefaultSelectionOverlay(),
                          onSelectedItemChanged: (index) {
                            SyncHaptics.selection();
                            setState(() => _unit = _ReminderUnit.values[index]);
                          },
                          children: const [
                            Center(child: Text('Day')),
                            Center(child: Text('Week')),
                            Center(child: Text('Month')),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Center(child: _PickerSelectedText('Before')),
                      ),
                    ],
                  ),
                ),
                const _HorizontalDivider(),
                _SheetRow(
                  icon: SyncIcons.time,
                  label: 'Time',
                  onTap: _pickTime,
                  trailing: _ValuePill(label: _timeOfDayLabel(_time)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _summary(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  DateTime _reminderDateTime() {
    final target = DateTime(
      widget.baseDate.year,
      widget.baseDate.month,
      widget.baseDate.day,
      _time.hour,
      _time.minute,
    );
    return switch (_unit) {
      _ReminderUnit.day => target.subtract(Duration(days: _amount)),
      _ReminderUnit.week => target.subtract(Duration(days: _amount * 7)),
      _ReminderUnit.month => _subtractMonths(target, _amount),
    };
  }

  DateTime _subtractMonths(DateTime value, int months) {
    final target = DateTime(value.year, value.month - months);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    final day = value.day > lastDay ? lastDay : value.day;
    return DateTime(target.year, target.month, day, value.hour, value.minute);
  }

  String _summary() {
    final value = _reminderDateTime();
    return 'Remind on ${_monthLabel(value.month)} ${value.day} at ${_timeOfDayLabel(_time)}';
  }

  String _timeOfDayLabel(TimeOfDay value) {
    final period = value.hour < 12 ? 'AM' : 'PM';
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    return '$hour:${value.minute.toString().padLeft(2, '0')} $period';
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

  ButtonStyle _sheetTopActionStyle(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return OutlinedButton.styleFrom(
      backgroundColor: colors.surfaceSecondary,
      foregroundColor: colors.textPrimary,
      minimumSize: const Size(0, 42),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}

class _PickerSelectedText extends StatelessWidget {
  const _PickerSelectedText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    );
  }
}

enum _RepeatUnit { day, week, month }

class _CustomRepeatResult {
  const _CustomRepeatResult({
    required this.recurrenceType,
    required this.label,
    required this.interval,
  });

  final RecurrenceType recurrenceType;
  final String label;
  final int interval;
}

class _CustomRepeatSheet extends StatefulWidget {
  const _CustomRepeatSheet({
    required this.initialUnit,
    this.initialInterval = 1,
  });

  final _RepeatUnit initialUnit;
  final int initialInterval;

  @override
  State<_CustomRepeatSheet> createState() => _CustomRepeatSheetState();
}

class _CustomRepeatSheetState extends State<_CustomRepeatSheet> {
  late final cupertino.FixedExtentScrollController _amountController;
  late final cupertino.FixedExtentScrollController _unitController;
  late int _amount;
  late _RepeatUnit _unit;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialInterval.clamp(1, 30);
    _unit = widget.initialUnit;
    _amountController = cupertino.FixedExtentScrollController(
      initialItem: _amount - 1,
    );
    _unitController = cupertino.FixedExtentScrollController(
      initialItem: _unit.index,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.58;
    return AppBottomSheet(
      minHeight: maxSheetHeight < 380 ? maxSheetHeight : 380,
      maxHeight: maxSheetHeight,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
      handleGap: 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 76,
                child: OutlinedButton(
                  onPressed: () {
                    SyncHaptics.selection();
                    Navigator.of(context).pop();
                  },
                  style: _sheetTopActionStyle(context),
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Custom Repeat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 76,
                child: OutlinedButton(
                  key: const Key('custom-repeat-done-button'),
                  onPressed: () {
                    SyncHaptics.action();
                    Navigator.of(context).pop(_result());
                  },
                  style: _sheetTopActionStyle(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SizedBox(
              height: 136,
              child: Row(
                children: [
                  const SizedBox(
                    width: 60,
                    child: Center(child: _PickerSelectedText('Every')),
                  ),
                  Expanded(
                    child: cupertino.CupertinoPicker(
                      scrollController: _amountController,
                      itemExtent: 42,
                      magnification: 1.02,
                      squeeze: 1.08,
                      selectionOverlay:
                          const cupertino.CupertinoPickerDefaultSelectionOverlay(),
                      onSelectedItemChanged: (index) {
                        SyncHaptics.selection();
                        setState(() => _amount = index + 1);
                      },
                      children: [
                        for (var value = 1; value <= 30; value++)
                          Center(
                            child: Text(
                              '$value',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: cupertino.CupertinoPicker(
                      scrollController: _unitController,
                      itemExtent: 42,
                      magnification: 1.02,
                      squeeze: 1.08,
                      selectionOverlay:
                          const cupertino.CupertinoPickerDefaultSelectionOverlay(),
                      onSelectedItemChanged: (index) {
                        SyncHaptics.selection();
                        setState(() => _unit = _RepeatUnit.values[index]);
                      },
                      children: [
                        for (final unit in _RepeatUnit.values)
                          Center(
                            child: Text(
                              _unitName(unit, _amount),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _summary(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _CustomRepeatResult _result() {
    final type = switch (_unit) {
      _RepeatUnit.day => RecurrenceType.daily,
      _RepeatUnit.week => RecurrenceType.weekly,
      _RepeatUnit.month => RecurrenceType.monthly,
    };
    final unitStr = _unitName(_unit, _amount);
    final label = _amount == 1
        ? 'Every ${_unit.name}'
        : 'Every $_amount $unitStr';
    return _CustomRepeatResult(
      recurrenceType: type,
      label: label,
      interval: _amount,
    );
  }

  String _unitName(_RepeatUnit unit, int amount) {
    return switch (unit) {
      _RepeatUnit.day => amount == 1 ? 'day' : 'days',
      _RepeatUnit.week => amount == 1 ? 'week' : 'weeks',
      _RepeatUnit.month => amount == 1 ? 'month' : 'months',
    };
  }

  String _summary() {
    final unitStr = _unitName(_unit, _amount);
    if (_amount == 1) {
      return 'Task will repeat every ${_unit.name}.';
    }
    return 'Task will repeat every $_amount $unitStr.';
  }

  ButtonStyle _sheetTopActionStyle(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return OutlinedButton.styleFrom(
      backgroundColor: colors.surfaceSecondary,
      foregroundColor: colors.textPrimary,
      minimumSize: const Size(0, 42),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}


