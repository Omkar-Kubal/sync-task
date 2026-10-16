import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock/local_clock_provider.dart';
import '../../lists/providers/list_tasks_provider.dart';

class TaskListLifecycleRefresh extends ConsumerStatefulWidget {
  const TaskListLifecycleRefresh({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<TaskListLifecycleRefresh> createState() =>
      _TaskListLifecycleRefreshState();
}

class _TaskListLifecycleRefreshState
    extends ConsumerState<TaskListLifecycleRefresh>
    with WidgetsBindingObserver {
  Timer? _minuteTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextMinute();
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      invalidateTaskListProviders(ref);
      ref.invalidate(localClockProvider);
      _scheduleNextMinute();
    } else {
      _minuteTimer?.cancel();
    }
  }

  void _scheduleNextMinute() {
    _minuteTimer?.cancel();
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    _minuteTimer = Timer(nextMinute.difference(now), () {
      if (!mounted) {
        return;
      }
      ref.invalidate(localClockProvider);
      _scheduleNextMinute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}


