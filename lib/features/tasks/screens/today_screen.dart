import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctask_color_scheme.dart';
import '../../focus/domain/focus_launch.dart';
import '../../../shared/widgets/sync_fab.dart';
import '../domain/task.dart' as domain;
import '../providers/task_controller.dart';
import '../providers/today_tasks_provider.dart';
import '../providers/upcoming_tasks_provider.dart';
import '../widgets/task_create_sheet.dart';
import '../widgets/task_edit_sheet.dart';
import '../widgets/task_row.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final colors = SyncTaskColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final tasksValue = ref.watch(todayTasksProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Today',
                    style: textTheme.displaySmall?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('d').format(now),
                      style: textTheme.headlineLarge?.copyWith(
                        color: colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM').format(now),
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'More options',
                  child: IconButton(
                    onPressed: () => _showMoreMenu(context),
                    tooltip: 'More options',
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.textPrimary,
                      padding: EdgeInsets.zero,
                      side: BorderSide.none,
                      shape: const CircleBorder(),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.more_horiz, size: 22),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _TodayBody(
                tasksValue: tasksValue,
                onCreate: () => _showCreateSheet(context, ref),
                onTaskTap: (task) => _showEditSheet(context, ref, task: task),
                onComplete: (task) => unawaited(_completeTask(ref, task.id)),
                onDelete: (task) => unawaited(_deleteTask(ref, task.id)),
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

  Future<void> _showMoreMenu(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: colors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );

    return showMenu<void>(
      context: context,
      color: colors.surface,
      elevation: 10,
      shadowColor: colors.textPrimary.withValues(alpha: 0.12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.divider),
        borderRadius: BorderRadius.circular(24),
      ),
      position: RelativeRect.fromLTRB(screenWidth - 212, 64, 20, 0),
      items: [
        PopupMenuItem<void>(
          height: 54,
          child: _HomeMenuRow(
            icon: Icons.tune,
            label: 'View',
            textStyle: textStyle,
          ),
        ),
        PopupMenuDivider(height: 1, color: colors.divider),
        PopupMenuItem<void>(
          height: 54,
          child: _HomeMenuRow(
            icon: Icons.copy_outlined,
            label: 'Select tasks',
            textStyle: textStyle,
          ),
        ),
      ],
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
            onSubmit: (title) =>
                unawaited(_createTask(sheetContext, ref, title)),
            onTodaySelected: () {
              Navigator.of(sheetContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _showEditSheet(context, ref);
                }
              });
            },
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, {Task? task}) {
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
            title: task?.title ?? '',
            scheduledDate: task?.scheduledDate ?? _todayDate(),
            scheduledTime: task?.scheduledTime,
            reminderTime: task?.reminderTime,
            focusDurationMinutes: task?.focusDurationMinutes,
            onCancel: () => Navigator.of(sheetContext).pop(),
            onDone: () => Navigator.of(sheetContext).pop(),
            onStartFocus: () =>
                _startFocusFromTask(context, sheetContext, task),
            onStartFocusWithUpdate: task == null
                ? null
                : (update) => _saveAndStartFocusFromTask(
                    context,
                    sheetContext,
                    ref,
                    task,
                    update,
                  ),
            onSave: task == null
                ? (update) => _createTaskFromUpdate(ref, update)
                : (update) => _updateTask(ref, task.id, update),
          ),
        );
      },
    );
  }

  Future<void> _createTask(
    BuildContext sheetContext,
    WidgetRef ref,
    String title,
  ) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await ref
        .read(taskControllerProvider)
        .create(
          domain.TaskDraft(
            title: trimmedTitle,
            scheduledDate: DateTime(now.year, now.month, now.day),
          ),
        );
    _invalidateTaskLists(ref);
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
  }

  Future<void> _createTaskFromUpdate(
    WidgetRef ref,
    TaskEditUpdate update,
  ) async {
    await ref.read(taskControllerProvider).create(_draftFromUpdate(update));
    _invalidateTaskLists(ref);
  }

  Future<void> _completeTask(WidgetRef ref, int taskId) async {
    await ref.read(taskControllerProvider).complete(taskId);
    _invalidateTaskLists(ref);
  }

  Future<void> _updateTask(
    WidgetRef ref,
    int taskId,
    TaskEditUpdate update,
  ) async {
    await ref
        .read(taskControllerProvider)
        .updateTask(taskId, _draftFromUpdate(update));
    _invalidateTaskLists(ref);
  }

  Future<void> _saveAndStartFocusFromTask(
    BuildContext context,
    BuildContext sheetContext,
    WidgetRef ref,
    Task task,
    TaskEditUpdate update,
  ) async {
    if (update.focusDurationMinutes == null) {
      return;
    }
    await _updateTask(ref, task.id, update);
    if (!context.mounted || !sheetContext.mounted) {
      return;
    }
    Navigator.of(sheetContext).pop();
    context.go(
      '/focus',
      extra: FocusLaunch(
        taskId: task.id,
        taskTitle: update.title,
        duration: Duration(minutes: update.focusDurationMinutes!),
      ),
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
    );
  }

  DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void _startFocusFromTask(
    BuildContext context,
    BuildContext sheetContext,
    Task? task,
  ) {
    final focusDurationMinutes = task?.focusDurationMinutes;
    if (task == null || focusDurationMinutes == null) {
      return;
    }
    Navigator.of(sheetContext).pop();
    context.go(
      '/focus',
      extra: FocusLaunch(
        taskId: task.id,
        taskTitle: task.title,
        duration: Duration(minutes: focusDurationMinutes),
      ),
    );
  }

  Future<void> _deleteTask(WidgetRef ref, int taskId) async {
    await ref.read(taskControllerProvider).delete(taskId);
    _invalidateTaskLists(ref);
  }

  void _invalidateTaskLists(WidgetRef ref) {
    ref.invalidate(todayTasksProvider);
    ref.invalidate(upcomingTasksProvider);
  }
}

class _TodayBody extends StatelessWidget {
  const _TodayBody({
    required this.tasksValue,
    required this.onCreate,
    required this.onTaskTap,
    required this.onComplete,
    required this.onDelete,
  });

  final AsyncValue<List<Task>> tasksValue;
  final VoidCallback onCreate;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onComplete;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    return tasksValue.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _EmptyTodayState(onCreate: onCreate);
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 26, bottom: 108),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskRow(
              title: task.title,
              metadata: _metadataFor(task),
              onTap: () => onTaskTap(task),
              onComplete: () => onComplete(task),
              onDelete: () => onDelete(task),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 2),
          itemCount: tasks.length,
        );
      },
      loading: () => _EmptyTodayState(onCreate: onCreate),
      error: (error, stackTrace) => _EmptyTodayState(onCreate: onCreate),
    );
  }

  String? _metadataFor(Task task) {
    return 'Inbox';
  }
}

class _EmptyTodayState extends StatelessWidget {
  const _EmptyTodayState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Transform.translate(
                offset: const Offset(0, -8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _EmptyTaskIllustration(),
                    const SizedBox(height: 22),
                    Text(
                      'No tasks found',
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Looks like you're all clear for today.",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        height: 1.34,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create a task to get started.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        height: 1.34,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: onCreate,
                      style: FilledButton.styleFrom(
                        fixedSize: const Size(160, 40),
                        minimumSize: const Size(160, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      child: Text(
                        'Create new task',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.controlForeground,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyTaskIllustration extends StatelessWidget {
  const _EmptyTaskIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return SizedBox(
      width: 168,
      height: 128,
      child: CustomPaint(
        painter: _EmptyTaskIllustrationPainter(colors: colors),
      ),
    );
  }
}

class _HomeMenuRow extends StatelessWidget {
  const _HomeMenuRow({
    required this.icon,
    required this.label,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Row(
      children: [
        Icon(icon, color: colors.textPrimary, size: 22),
        const SizedBox(width: 18),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _EmptyTaskIllustrationPainter extends CustomPainter {
  const _EmptyTaskIllustrationPainter({required this.colors});

  final SyncTaskColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.62);
    final haze = Paint()
      ..color = colors.surfaceSecondary.withValues(alpha: 0.34)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.96,
        height: size.height * 0.86,
      ),
      haze,
    );

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.28, 16, 104, 138),
      const Radius.circular(24),
    );
    final cardPaint = Paint()..color = colors.surface.withValues(alpha: 0.94);
    canvas.drawRRect(cardRect, cardPaint);

    final iconPaint = Paint()
      ..color = colors.surfaceSecondary.withValues(alpha: 0.78);
    canvas.drawCircle(Offset(size.width * 0.48, 64), 26, iconPaint);

    final checkPaint = Paint()
      ..color = colors.surface
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(size.width * 0.42, 64)
      ..lineTo(size.width * 0.47, 70)
      ..lineTo(size.width * 0.55, 58);
    canvas.drawPath(checkPath, checkPaint);

    final linePaint = Paint()
      ..color = colors.surfaceSecondary.withValues(alpha: 0.58)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.36, 112),
      Offset(size.width * 0.72, 112),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.36, 134),
      Offset(size.width * 0.58, 134),
      linePaint,
    );

    final calendarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.58, 100, 86, 70),
      const Radius.circular(18),
    );
    canvas.drawRRect(calendarRect, cardPaint);

    final bindingPaint = Paint()
      ..color = colors.textPrimary.withValues(alpha: 0.9)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.65, 96),
      Offset(size.width * 0.65, 110),
      bindingPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.84, 96),
      Offset(size.width * 0.84, 110),
      bindingPaint,
    );

    final dotPaint = Paint()
      ..color = colors.textSecondary.withValues(alpha: 0.34);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        canvas.drawCircle(
          Offset(size.width * 0.64 + col * 16, 130 + row * 16),
          3.8,
          dotPaint,
        );
      }
    }

    _drawSparkle(canvas, Offset(size.width * 0.10, 58), 20);
    _drawSparkle(canvas, Offset(size.width * 0.86, 18), 14);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = colors.textSecondary.withValues(alpha: 0.28);
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy - radius * 0.18,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy + radius * 0.18,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy + radius * 0.18,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy - radius * 0.18,
        center.dx,
        center.dy - radius,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EmptyTaskIllustrationPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }
}
