import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/synctask_color_scheme.dart';
import '../../../shared/widgets/sync_fab.dart';
import '../widgets/task_create_sheet.dart';
import '../widgets/task_edit_sheet.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colors = SyncTaskColorScheme.of(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 34, 18, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                              height: 1.02,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        DateFormat('EEEE, MMMM d').format(now),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Search',
                  child: IconButton(
                    onPressed: () {},
                    tooltip: 'Search',
                    constraints: const BoxConstraints.tightFor(
                      width: 60,
                      height: 60,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.textSecondary,
                      side: BorderSide(color: colors.divider),
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.search, size: 34),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No tasks found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => _showCreateSheet(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(190, 50),
                      textStyle: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                    ),
                    child: const Text('Create new task'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SyncFab(
        onPressed: () => _showCreateSheet(context),
        semanticLabel: 'Create task',
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: TaskCreateSheet(
            onSubmit: (_) => Navigator.of(sheetContext).pop(),
            onTodaySelected: () {
              Navigator.of(sheetContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _showEditSheet(context);
                }
              });
            },
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: TaskEditSheet(
            title: '',
            focusDurationMinutes: 45,
            onCancel: () => Navigator.of(sheetContext).pop(),
            onDone: () => Navigator.of(sheetContext).pop(),
            onStartFocus: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }
}
