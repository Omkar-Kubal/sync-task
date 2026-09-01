import 'package:flutter/material.dart';

import '../../../core/theme/synctask_color_scheme.dart';
import '../../../shared/sheets/app_bottom_sheet.dart';

class TaskCreateSheet extends StatefulWidget {
  const TaskCreateSheet({
    required this.onSubmit,
    required this.onTodaySelected,
    super.key,
  });

  final ValueChanged<String> onSubmit;
  final VoidCallback onTodaySelected;

  @override
  State<TaskCreateSheet> createState() => _TaskCreateSheetState();
}

class _TaskCreateSheetState extends State<TaskCreateSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return AppBottomSheet(
      minHeight: 330,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 92,
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.15,
              ),
              cursorColor: const Color(0xFF9BCFFF),
              cursorWidth: 3,
              decoration: InputDecoration(
                hintText: 'Task title',
                filled: false,
                contentPadding: EdgeInsets.zero,
                hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.textSecondary.withValues(alpha: 0.72),
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: _chipStyle(context),
                        icon: const Icon(Icons.inbox, size: 20),
                        label: const Text('Inbox'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: widget.onTodaySelected,
                        style: _chipStyle(context),
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                        ),
                        label: const Text('Today'),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Flag task',
                        button: true,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: _chipStyle(context).copyWith(
                            minimumSize: const WidgetStatePropertyAll(
                              Size(44, 44),
                            ),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.zero,
                            ),
                          ),
                          child: const ExcludeSemantics(
                            child: Icon(Icons.flag_outlined, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox.square(
                dimension: 52,
                child: IconButton.filled(
                  onPressed: () => widget.onSubmit(_controller.text),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.controlPrimary,
                    foregroundColor: colors.controlForeground,
                    side: BorderSide.none,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.arrow_upward, size: 28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _chipStyle(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return OutlinedButton.styleFrom(
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      side: BorderSide(color: colors.divider, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}
