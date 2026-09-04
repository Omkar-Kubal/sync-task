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
  static const _defaultFocusDuration = Duration(minutes: 25);
  static const _minFocusMinutes = 1;
  static const _maxFocusMinutes = 60;

  bool _locallyRunning = false;
  Duration _selectedDuration = _defaultFocusDuration;
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
            const _FocusHeader(),
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
                          setState(
                            () => _selectedDuration = _defaultFocusDuration,
                          );
                        },
                        onStart: () => unawaited(_startFocus()),
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
    await ref.read(focusControllerProvider).start(duration: _selectedDuration);
    if (mounted) {
      setState(() => _locallyRunning = true);
    }
  }

  void _changeSelectedDuration(Duration delta) {
    final next = _selectedDuration + delta;
    setState(() {
      _selectedDuration = next.clampMinutes(
        min: _minFocusMinutes,
        max: _maxFocusMinutes,
      );
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
}

class _FocusHeader extends StatelessWidget {
  const _FocusHeader();

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

  final Duration selectedDuration;
  final ValueChanged<Duration> onDurationChanged;
  final VoidCallback onResetDuration;
  final VoidCallback? onStart;
  final int streak;
  final VoidCallback onViewInsights;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 620;
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: compact ? 18 : 28, bottom: 108),
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
                  compact: compact,
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
    required this.compact,
  });

  final Duration selectedDuration;
  final ValueChanged<Duration> onDurationChanged;
  final VoidCallback onResetDuration;
  final VoidCallback? onStart;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: EdgeInsets.fromLTRB(
        18,
        compact ? 16 : 20,
        18,
        compact ? 20 : 26,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.divider.withValues(alpha: 0.86)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface.withValues(alpha: 0.98),
            colors.surfaceSecondary.withValues(alpha: 0.42),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Set Timer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onResetDuration,
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  minimumSize: const Size(82, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: colors.divider.withValues(alpha: 0.72),
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset'),
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 22),
          _SetTimerDial(
            duration: selectedDuration,
            onDurationChanged: onDurationChanged,
            maxMinutes: _FocusScreenState._maxFocusMinutes,
            size: compact ? 202 : 254,
          ),
          SizedBox(height: compact ? 18 : 28),
          Semantics(
            button: true,
            label: 'Start focus',
            child: SizedBox.square(
              dimension: compact ? 50 : 58,
              child: IconButton(
                key: const Key('focus-start-button'),
                onPressed: onStart,
                style: IconButton.styleFrom(
                  backgroundColor: colors.surface.withValues(alpha: 0.32),
                  foregroundColor: colors.textPrimary,
                  shape: const CircleBorder(),
                  side: BorderSide(
                    color: colors.textPrimary.withValues(alpha: 0.76),
                  ),
                  shadowColor: colors.textPrimary.withValues(alpha: 0.18),
                  elevation: 8,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetTimerDial extends StatefulWidget {
  const _SetTimerDial({
    required this.duration,
    required this.onDurationChanged,
    required this.maxMinutes,
    required this.size,
  });

  final Duration duration;
  final ValueChanged<Duration> onDurationChanged;
  final int maxMinutes;
  final double size;

  @override
  State<_SetTimerDial> createState() => _SetTimerDialState();
}

class _SetTimerDialState extends State<_SetTimerDial> {
  ScrollHoldController? _scrollHold;

  void _handlePointerDown(PointerDownEvent event) {
    _scrollHold?.cancel();
    _scrollHold = Scrollable.maybeOf(context)?.position.hold(() {});
    _updateDurationFromPosition(event.localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _updateDurationFromPosition(event.localPosition);
  }

  void _handlePointerEnd(PointerEvent event) {
    _scrollHold?.cancel();
    _scrollHold = null;
  }

  @override
  void dispose() {
    _scrollHold?.cancel();
    super.dispose();
  }

  void _updateDurationFromPosition(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final vector = localPosition - center;
    if (vector.distance < widget.size * 0.18) {
      return;
    }

    final angle = math.atan2(vector.dy, vector.dx);
    final normalized = (angle + math.pi / 2) % (math.pi * 2);
    final minutes = (normalized / (math.pi * 2) * widget.maxMinutes)
        .round()
        .clamp(1, widget.maxMinutes);
    final next = Duration(minutes: minutes);
    if (next != widget.duration) {
      widget.onDurationChanged(next - widget.duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final minutes = widget.duration.inMinutes;
    final progress = (minutes / widget.maxMinutes).clamp(0.02, 1).toDouble();

    return Semantics(
      label: 'Set timer duration $minutes minutes',
      child: Listener(
        key: const Key('focus-duration-dial'),
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerEnd,
        onPointerCancel: _handlePointerEnd,
        child: SizedBox.square(
          dimension: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(widget.size),
                painter: _SetTimerDialPainter(
                  progress: progress,
                  colors: colors,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$minutes',
                        style: textTheme.displayLarge?.copyWith(
                          color: colors.textPrimary,
                          fontSize: 60,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 0.92,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'min',
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Focus session',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetTimerDialPainter extends CustomPainter {
  const _SetTimerDialPainter({required this.progress, required this.colors});

  final double progress;
  final SyncTaskColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final strokeWidth = 8.0;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 2 * progress;

    final trackPaint = Paint()
      ..color = colors.divider.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + math.pi * 2,
        colors: [
          colors.textPrimary.withValues(alpha: 0.95),
          colors.textSecondary.withValues(alpha: 0.82),
          colors.textPrimary.withValues(alpha: 0.95),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    for (var i = 0; i < 36; i += 1) {
      final tickAngle = startAngle + (math.pi * 2 * i / 36);
      final isMajor = i % 9 == 0;
      final tickLength = isMajor ? 10.0 : 5.0;
      final outer = Offset(
        center.dx + math.cos(tickAngle) * (radius - 20),
        center.dy + math.sin(tickAngle) * (radius - 20),
      );
      final inner = Offset(
        center.dx + math.cos(tickAngle) * (radius - 20 - tickLength),
        center.dy + math.sin(tickAngle) * (radius - 20 - tickLength),
      );
      final tickPaint = Paint()
        ..color = colors.textPrimary.withValues(alpha: isMajor ? 0.72 : 0.24)
        ..strokeWidth = isMajor ? 2 : 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(inner, outer, tickPaint);
    }

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    final knobAngle = startAngle + sweepAngle;
    final knob = Offset(
      center.dx + math.cos(knobAngle) * radius,
      center.dy + math.sin(knobAngle) * radius,
    );
    canvas.drawCircle(
      knob,
      23,
      Paint()..color = colors.textPrimary.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      knob,
      14,
      Paint()
        ..color = colors.textPrimary
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
    );
    canvas.drawCircle(
      knob,
      14,
      Paint()..color = colors.surface.withValues(alpha: 0.24),
    );
    canvas.drawCircle(knob, 10, Paint()..color = colors.textPrimary);
  }

  @override
  bool shouldRepaint(covariant _SetTimerDialPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.colors != colors;
  }
}

extension on Duration {
  Duration clampMinutes({required int min, required int max}) {
    final minutes = inMinutes.clamp(min, max);
    return Duration(minutes: minutes);
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
