import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      invalidateTaskListProviders(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}


