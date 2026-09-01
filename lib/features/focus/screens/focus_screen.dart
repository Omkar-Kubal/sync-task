import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/synctask_color_scheme.dart';
import '../domain/active_focus.dart';
import '../domain/focus_status.dart';
import '../providers/focus_controller.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  static const _defaultDuration = Duration(minutes: 25);

  bool _locallyRunning = false;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(focusControllerProvider);
    final activeFocus = controller.activeFocus;
    final isRunning =
        _locallyRunning ||
        activeFocus?.status == FocusStatus.running ||
        activeFocus?.status == FocusStatus.paused;

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
                child: isRunning
                    ? _RunningFocusBody(
                        key: const ValueKey('focus-running'),
                        activeFocus: activeFocus,
                        onStop: () => unawaited(_stopFocus()),
                        onResume: () => unawaited(_resumeFocus()),
                        onPause: () => unawaited(_pauseFocus()),
                      )
                    : _IdleFocusBody(
                        key: const ValueKey('focus-idle'),
                        onStart: () => unawaited(_startFocus()),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startFocus() async {
    await ref.read(focusControllerProvider).start(duration: _defaultDuration);
    if (mounted) {
      setState(() => _locallyRunning = true);
    }
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
        borderRadius: BorderRadius.circular(18),
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
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1,
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
  const _IdleFocusBody({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 48, bottom: 108),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 108),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _StopwatchMark(
                  key: Key('focus-idle-stopwatch'),
                  size: 170,
                  showSparkles: true,
                ),
                const SizedBox(height: 38),
                _SetTimePanel(onStart: onStart),
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
    required this.onStop,
    required this.onResume,
    required this.onPause,
    super.key,
  });

  final ActiveFocus? activeFocus;
  final VoidCallback onStop;
  final VoidCallback onResume;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      CustomPaint(
                        size: Size.square(280),
                        painter: _FocusRingPainter(),
                      ),
                      _StopwatchMark(size: 86, showSparkles: false),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  _remainingLabel(activeFocus),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 54,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 22),
                const _TaskAttachment(),
                const SizedBox(height: 18),
                _FocusControls(
                  onStop: onStop,
                  onResume: onResume,
                  onPause: onPause,
                ),
                const SizedBox(height: 22),
                const _StreakCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  String _remainingLabel(ActiveFocus? activeFocus) {
    final duration =
        activeFocus?.plannedDuration ?? const Duration(minutes: 25);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes';
    }
    return '$minutes:00';
  }
}

class _SetTimePanel extends StatelessWidget {
  const _SetTimePanel({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 17),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  minimumSize: const Size(84, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  side: BorderSide(color: colors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _TimeColumn(
                previous: '23',
                current: '00',
                next: '01',
                label: 'HH',
              ),
              _Colon(),
              _TimeColumn(
                previous: '59',
                current: '25',
                next: '26',
                label: 'MM',
              ),
              _Colon(),
              _TimeColumn(
                previous: '59',
                current: '00',
                next: '01',
                label: 'SS',
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
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.previous,
    required this.current,
    required this.next,
    required this.label,
  });

  final String previous;
  final String current;
  final String next;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 74,
      child: Column(
        children: [
          Text(
            previous,
            style: textTheme.titleLarge?.copyWith(
              color: colors.textSecondary,
              fontSize: 16,
              letterSpacing: 0,
            ),
          ),
          Divider(height: 22, color: colors.divider),
          Text(
            current,
            style: textTheme.headlineMedium?.copyWith(
              color: colors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1,
            ),
          ),
          Divider(height: 22, color: colors.divider),
          Text(
            next,
            style: textTheme.titleLarge?.copyWith(
              color: colors.textSecondary,
              fontSize: 16,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
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

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return Text(
      ':',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: SyncTaskColorScheme.of(context).textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _TaskAttachment extends StatelessWidget {
  const _TaskAttachment();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: colors.textPrimary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Task: Study',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w500,
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
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
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
              'Streak 3 days',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w500,
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

class _StopwatchMark extends StatelessWidget {
  const _StopwatchMark({
    required this.size,
    required this.showSparkles,
    super.key,
  });

  final double size;
  final bool showSparkles;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StopwatchPainter(
          colors: SyncTaskColorScheme.of(context),
          showSparkles: showSparkles,
        ),
      ),
    );
  }
}

class _StopwatchPainter extends CustomPainter {
  const _StopwatchPainter({required this.colors, required this.showSparkles});

  final SyncTaskColorScheme colors;
  final bool showSparkles;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.56);
    final radius = size.width * 0.34;
    final shadow = Paint()
      ..color = colors.textPrimary.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center.translate(0, 6), radius, shadow);

    final body = Paint()
      ..color = colors.surface
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = colors.surfaceSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.028;
    canvas.drawCircle(center, radius, body);
    canvas.drawCircle(center, radius, outline);

    final face = Paint()
      ..color = colors.scaffold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.72, face);
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = colors.surfaceSecondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012,
    );

    final topRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.17),
        width: size.width * 0.24,
        height: size.height * 0.10,
      ),
      Radius.circular(size.width * 0.025),
    );
    canvas.drawRRect(topRect, body);
    canvas.drawRRect(
      topRect,
      Paint()
        ..color = colors.surfaceSecondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.01,
    );

    final sideRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.70, size.height * 0.27),
        width: size.width * 0.10,
        height: size.height * 0.18,
      ),
      Radius.circular(size.width * 0.025),
    );
    canvas.save();
    canvas.translate(size.width * 0.70, size.height * 0.27);
    canvas.rotate(-0.78);
    canvas.translate(-size.width * 0.70, -size.height * 0.27);
    canvas.drawRRect(sideRect, body);
    canvas.drawRRect(
      sideRect,
      Paint()
        ..color = colors.surfaceSecondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012,
    );
    canvas.restore();

    final hand = Paint()
      ..color = colors.textPrimary
      ..strokeWidth = size.width * 0.032
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(size.width * 0.62, size.height * 0.43),
      hand,
    );
    canvas.drawCircle(
      center,
      size.width * 0.042,
      Paint()..color = colors.surface,
    );
    canvas.drawCircle(
      center,
      size.width * 0.042,
      Paint()
        ..color = colors.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.022,
    );

    if (showSparkles) {
      _drawSparkle(
        canvas,
        Offset(size.width * 0.10, size.height * 0.26),
        size.width * 0.045,
      );
      _drawSparkle(
        canvas,
        Offset(size.width * 0.88, size.height * 0.10),
        size.width * 0.04,
      );
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = colors.textSecondary.withValues(alpha: 0.28);
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius * 0.28, center.dy - radius * 0.28)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + radius * 0.28, center.dy + radius * 0.28)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius * 0.28, center.dy + radius * 0.28)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - radius * 0.28, center.dy - radius * 0.28)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StopwatchPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.showSparkles != showSparkles;
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFB6C2D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    final knob = Offset(center.dx, center.dy - radius);
    canvas.drawCircle(knob, 9, Paint()..color = Colors.white);
    canvas.drawCircle(
      knob,
      9,
      Paint()
        ..color = const Color(0xFFE4E8EE)
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) => false;
}
