import 'package:flutter/material.dart';

class FocusTimerDisplay extends StatelessWidget {
  const FocusTimerDisplay({required this.remaining, super.key});

  final Duration? remaining;

  @override
  Widget build(BuildContext context) {
    final duration = remaining;
    final label = duration == null
        ? '--:--'
        : '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
              '${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Text(
      label,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
