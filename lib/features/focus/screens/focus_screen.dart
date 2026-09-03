import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/synctask_color_scheme.dart';
import '../domain/active_focus.dart';
import '../domain/focus_launch.dart';
import '../domain/focus_status.dart';
import '../providers/focus_controller.dart';
import '../providers/focus_streak_provider.dart';
import '../widgets/focus_completion_sheet.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({this.launch, super.key});

  final FocusLaunch? launch;

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  bool _locallyRunning = false;
  Duration? _selectedDuration;
  bool _launchConsumed = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final controller = ref.read(focusControllerProvider);
      unawaited(controller.resolveExpired());
      if (mounted && controller.activeFocus != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(focusControllerProvider);
    final streak = ref
        .watch(focusStreakProvider)
        .maybeWhen(data: (value) => value, orElse: () => 0);
    _consumeLaunch(controller);
    final activeFocus = controller.activeFocus;
    final isRunning =
        _locallyRunning ||
        activeFocus?.status == FocusStatus.running ||
        activeFocus?.status == FocusStatus.paused;
    final isRinging = activeFocus?.status == FocusStatus.ringing;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FocusHeader(onMore: () => _showMoreMenu(context)),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isRinging
                    ? _CompletionFocusBody(
                        key: const ValueKey('focus-complete'),
                        activeFocus: activeFocus!,
                        onExtendFive: () =>
                            unawaited(_extendFocus(const Duration(minutes: 5))),
                        onExtendTen: () => unawaited(
                          _extendFocus(const Duration(minutes: 10)),
                        ),
                        onDismiss: () => unawaited(_dismissCompletion()),
                      )
                    : isRunning
                    ? _RunningFocusBody(
                        key: const ValueKey('focus-running'),
                        activeFocus: activeFocus,
                        remaining: controller.remainingTime(),
                        onStop: () => unawaited(_stopFocus()),
                        onResume: () => unawaited(_resumeFocus()),
                        onPause: () => unawaited(_pauseFocus()),
                        streak: streak,
                      )
                    : _IdleFocusBody(
                        key: const ValueKey('focus-idle'),
                        selectedDuration: _selectedDuration,
                        onDurationChanged: _changeSelectedDuration,
                        onResetDuration: () {
                          setState(() => _selectedDuration = null);
                        },
                        onStart: _selectedDuration == null
                            ? null
                            : () => unawaited(_startFocus()),
                        streak: streak,
                        onViewInsights: () => context.go('/focus/insights'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _consumeLaunch(FocusController controller) {
    final launch = widget.launch;
    if (_launchConsumed || launch == null || controller.activeFocus != null) {
      return;
    }
    _launchConsumed = true;
    unawaited(
      controller
          .start(
            taskId: launch.taskId,
            taskTitle: launch.taskTitle,
            duration: launch.duration,
          )
          .then((_) {
            if (mounted) {
              setState(() => _locallyRunning = true);
            }
          }),
    );
  }

  Future<void> _startFocus() async {
    final duration = _selectedDuration;
    if (duration == null) {
      return;
    }
    await ref.read(focusControllerProvider).start(duration: duration);
    if (mounted) {
      setState(() => _locallyRunning = true);
    }
  }

  void _changeSelectedDuration(Duration delta) {
    final current = _selectedDuration ?? Duration.zero;
    final next = current + delta;
    setState(() {
      _selectedDuration = next <= Duration.zero ? null : next;
    });
  }

  Future<void> _pauseFocus() async {
    final controller = ref.read(focusControllerProvider);
    if (controller.status == FocusStatus.running) {
      await controller.pause();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _resumeFocus() async {
    final controller = ref.read(focusControllerProvider);
    if (controller.status == FocusStatus.paused) {
      await controller.resume();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _stopFocus() async {
    await ref.read(focusControllerProvider).stop();
    if (mounted) {
      setState(() => _locallyRunning = false);
    }
  }

  Future<void> _extendFocus(Duration amount) async {
    await ref.read(focusControllerProvider).extend(amount);
    if (mounted) {
      setState(() => _locallyRunning = true);
    }
  }

  Future<void> _dismissCompletion() async {
    await ref.read(focusControllerProvider).dismissCompletion();
    if (mounted) {
      setState(() => _locallyRunning = false);
    }
  }

  Future<void> _showMoreMenu(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: colors.textPrimary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
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
          child: Row(
            children: [
              Icon(
                Icons.insights_outlined,
                color: colors.textPrimary,
                size: 22,
              ),
              const SizedBox(width: 18),
              Text('Insights', style: textStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class _FocusHeader extends StatelessWidget {
  const _FocusHeader({required this.onMore});

  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Focus',
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
        Semantics(
          button: true,
          label: 'More options',
          child: IconButton(
            onPressed: onMore,
            tooltip: 'More options',
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
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
    );
  }
}

class _IdleFocusBody extends StatelessWidget {
  const _IdleFocusBody({
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.onResetDuration,
    required this.onStart,
    required this.streak,
    required this.onViewInsights,
    super.key,
  });

  final Duration? selectedDuration;
  final ValueChanged<Duration> onDurationChanged;
  final VoidCallback onResetDuration;
  final VoidCallback? onStart;
  final int streak;
  final VoidCallback onViewInsights;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 28, bottom: 108),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 108),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SetTimePanel(
                  selectedDuration: selectedDuration,
                  onDurationChanged: onDurationChanged,
                  onResetDuration: onResetDuration,
                  onStart: onStart,
                ),
                const SizedBox(height: 16),
                _ViewInsightsCard(streak: streak, onPressed: onViewInsights),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RunningFocusBody extends StatelessWidget {
  const _RunningFocusBody({
    required this.activeFocus,
    required this.remaining,
    required this.onStop,
    required this.onResume,
    required this.onPause,
    required this.streak,
    super.key,
  });

  final ActiveFocus? activeFocus;
  final Duration remaining;
  final VoidCallback onStop;
  final VoidCallback onResume;
  final VoidCallback onPause;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final progress = _remainingProgress();
    final progressPercent = (progress * 100).round();
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 26, bottom: 108),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 108),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  key: const Key('focus-running-ring'),
                  width: 280,
                  height: 280,
                  child: Semantics(
                    label: 'Focus timer progress $progressPercent percent',
                    child: CustomPaint(
                      size: const Size.square(280),
                      painter: _FocusRingPainter(
                        progress: progress,
                        colors: colors,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  _remainingLabel(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 22),
                if (activeFocus?.taskTitle != null) ...[
                  _TaskAttachment(taskTitle: activeFocus?.taskTitle),
                  const SizedBox(height: 18),
                ],
                _FocusControls(
                  onStop: onStop,
                  onResume: onResume,
                  onPause: onPause,
                ),
                const SizedBox(height: 22),
                _StreakCard(streak: streak),
              ],
            ),
          ),
        );
      },
    );
  }

  String _remainingLabel() {
    final duration = remaining;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  double _remainingProgress() {
    final totalSeconds = activeFocus?.plannedDuration.inSeconds ?? 0;
    if (totalSeconds <= 0) {
      return 0;
    }
    return (remaining.inSeconds / totalSeconds).clamp(0, 1).toDouble();
  }
}

class _CompletionFocusBody extends StatelessWidget {
  const _CompletionFocusBody({
    required this.activeFocus,
    required this.onExtendFive,
    required this.onExtendTen,
    required this.onDismiss,
    super.key,
  });

  final ActiveFocus activeFocus;
  final VoidCallback onExtendFive;
  final VoidCallback onExtendTen;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final minutes = activeFocus.plannedDuration.inMinutes;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 80, bottom: 108),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 108),
            child: Center(
              child: FocusCompletionSheet(
                taskTitle: activeFocus.taskTitle,
                durationLabel: '$minutes min',
                onExtendFive: onExtendFive,
                onExtendTen: onExtendTen,
                onDismiss: onDismiss,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SetTimePanel extends StatelessWidget {
  const _SetTimePanel({
    required this.selectedDuration,
    required this.onDurationChanged,
    required this.onResetDuration,
    required this.onStart,
  });

  final Duration? selectedDuration;
  final ValueChanged<Duration> onDurationChanged;
  final VoidCallback onResetDuration;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Set time',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: selectedDuration == null ? null : onResetDuration,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  minimumSize: const Size(64, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: BorderSide(color: colors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeColumn(
                value: _hours,
                label: 'HH',
                onIncrease: () => onDurationChanged(const Duration(hours: 1)),
                onDecrease: _hours == 0
                    ? null
                    : () => onDurationChanged(const Duration(hours: -1)),
              ),
              const _Colon(),
              _TimeColumn(
                value: _minutes,
                label: 'MM',
                onIncrease: () => onDurationChanged(const Duration(minutes: 1)),
                onDecrease: _minutes == 0 && _hours == 0
                    ? null
                    : () => onDurationChanged(const Duration(minutes: -1)),
              ),
              const _Colon(),
              _TimeColumn(
                value: _seconds,
                label: 'SS',
                onIncrease: () =>
                    onDurationChanged(const Duration(seconds: 15)),
                onDecrease: _seconds == 0 && _minutes == 0 && _hours == 0
                    ? null
                    : () => onDurationChanged(const Duration(seconds: -15)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Semantics(
            button: true,
            label: 'Start focus',
            child: SizedBox.square(
              dimension: 44,
              child: IconButton.filled(
                key: const Key('focus-start-button'),
                onPressed: onStart,
                style: IconButton.styleFrom(
                  backgroundColor: colors.controlPrimary,
                  foregroundColor: colors.controlForeground,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int get _hours => selectedDuration?.inHours ?? 0;

  int get _minutes => selectedDuration?.inMinutes.remainder(60) ?? 0;

  int get _seconds => selectedDuration?.inSeconds.remainder(60) ?? 0;
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.value,
    required this.label,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int value;
  final String label;
  final VoidCallback onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 74,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DurationStepButton(
            icon: Icons.keyboard_arrow_up_rounded,
            semanticLabel: 'Increase ${label.toLowerCaseLabel()}',
            onPressed: onIncrease,
          ),
          Text(
            value.toString().padLeft(2, '0'),
            style: textTheme.headlineMedium?.copyWith(
              color: colors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1,
            ),
          ),
          _DurationStepButton(
            icon: Icons.keyboard_arrow_down_rounded,
            semanticLabel: 'Decrease ${label.toLowerCaseLabel()}',
            onPressed: onDecrease,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.textPrimary.withValues(alpha: 0.72),
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationStepButton extends StatelessWidget {
  const _DurationStepButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 34, height: 30),
        padding: EdgeInsets.zero,
        color: colors.textPrimary,
        disabledColor: colors.textSecondary.withValues(alpha: 0.35),
        icon: Icon(icon, size: 24),
      ),
    );
  }
}

extension on String {
  String toLowerCaseLabel() {
    return switch (this) {
      'HH' => 'hours',
      'MM' => 'minutes',
      'SS' => 'seconds',
      _ => toLowerCase(),
    };
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return Text(
      ':',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: SyncTaskColorScheme.of(context).textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _TaskAttachment extends StatelessWidget {
  const _TaskAttachment({this.taskTitle});

  final String? taskTitle;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: colors.textPrimary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              taskTitle == null ? 'Standalone Focus' : 'Task: $taskTitle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
          Icon(Icons.open_in_new, color: colors.textPrimary, size: 20),
        ],
      ),
    );
  }
}

class _FocusControls extends StatelessWidget {
  const _FocusControls({
    required this.onStop,
    required this.onResume,
    required this.onPause,
  });

  final VoidCallback onStop;
  final VoidCallback onResume;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundControl(
          icon: Icons.stop_rounded,
          semanticLabel: 'Stop focus',
          onPressed: onStop,
        ),
        const SizedBox(width: 28),
        _RoundControl(
          icon: Icons.play_arrow_rounded,
          semanticLabel: 'Resume focus',
          onPressed: onResume,
        ),
        const SizedBox(width: 28),
        _RoundControl(
          icon: Icons.pause_rounded,
          semanticLabel: 'Pause focus',
          onPressed: onPause,
        ),
      ],
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 54,
        child: IconButton(
          onPressed: onPressed,
          tooltip: semanticLabel,
          style: IconButton.styleFrom(
            backgroundColor: colors.surface,
            foregroundColor: colors.textPrimary,
            shape: const CircleBorder(),
            side: BorderSide(color: colors.divider),
          ),
          icon: Icon(icon, size: 28),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 23,
            color: colors.textPrimary,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Streak $streak ${streak == 1 ? 'day' : 'days'}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: colors.textPrimary, size: 26),
        ],
      ),
    );
  }
}

class _ViewInsightsCard extends StatelessWidget {
  const _ViewInsightsCard({required this.streak, required this.onPressed});

  final int streak;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Semantics(
      button: true,
      label: 'View Insights',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.divider),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.insights_outlined,
                  color: colors.textPrimary,
                  size: 23,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View Insights',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                              height: 1.1,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Streak $streak ${streak == 1 ? 'day' : 'days'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textPrimary, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({required this.progress, required this.colors});

  final double progress;
  final SyncTaskColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;
    final strokeWidth = 6.0;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 2 * progress;
    final trackPaint = Paint()
      ..color = colors.divider.withValues(alpha: 0.56)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = colors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }

    final knobAngle = startAngle + sweepAngle;
    final knob = Offset(
      center.dx + math.cos(knobAngle) * radius,
      center.dy + math.sin(knobAngle) * radius,
    );
    canvas.drawCircle(knob, 9, Paint()..color = Colors.white);
    canvas.drawCircle(
      knob,
      9,
      Paint()
        ..color = colors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.colors != colors;
  }
}
