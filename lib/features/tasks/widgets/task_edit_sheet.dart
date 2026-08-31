import 'package:flutter/material.dart';

import '../../../core/theme/synctask_color_scheme.dart';
import '../../../shared/sheets/app_bottom_sheet.dart';
import '../../../shared/widgets/sync_button.dart';

class TaskEditSheet extends StatelessWidget {
  const TaskEditSheet({
    required this.title,
    required this.onCancel,
    required this.onDone,
    required this.onStartFocus,
    this.focusDurationMinutes,
    super.key,
  });

  final String title;
  final int? focusDurationMinutes;
  final VoidCallback onCancel;
  final VoidCallback onDone;
  final VoidCallback onStartFocus;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return AppBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
              const Spacer(),
              Text('Edit Task', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              OutlinedButton(onPressed: onDone, child: const Text('Done')),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: TextEditingController(text: title),
            decoration: const InputDecoration(labelText: 'Task title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.textPrimary),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: const [
                Expanded(child: _QuickDateAction(icon: Icons.wb_sunny_outlined, label: 'Tomorrow')),
                _VerticalDivider(),
                Expanded(child: _QuickDateAction(icon: Icons.arrow_forward, label: 'Next Week')),
                _VerticalDivider(),
                Expanded(child: _QuickDateAction(icon: Icons.close, label: 'No Date')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _GroupedRows(children: [
            const _SheetRow(icon: Icons.calendar_month_outlined, label: 'Date', value: '31 Aug 2026'),
            const _SheetRow(icon: Icons.schedule, label: 'Time', value: 'Off'),
            _SheetRow(
              icon: Icons.adjust_outlined,
              label: 'Focus Timer',
              value: focusDurationMinutes == null ? 'None' : '$focusDurationMinutes min',
            ),
          ]),
          const SizedBox(height: 20),
          const _GroupedRows(children: [
            _SheetRow(icon: Icons.notifications_none, label: 'Reminder', value: 'None'),
            _SheetRow(icon: Icons.repeat, label: 'Repeat', value: 'None'),
          ]),
          const SizedBox(height: 24),
          SyncButton.primary(
            label: 'Start Focus',
            onPressed: focusDurationMinutes == null ? null : onStartFocus,
          ),
        ],
      ),
    );
  }
}

class _QuickDateAction extends StatelessWidget {
  const _QuickDateAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(label),
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
        border: Border.all(color: colors.textPrimary),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return SizedBox(height: 64, child: VerticalDivider(color: colors.divider));
  }
}
