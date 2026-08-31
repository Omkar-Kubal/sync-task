import 'package:flutter/material.dart';

import 'task_row.dart';

class TaskListItem {
  const TaskListItem({required this.title, this.metadata});

  final String title;
  final String? metadata;
}

class TaskListView extends StatelessWidget {
  const TaskListView({
    required this.tasks,
    required this.onTaskTap,
    required this.onComplete,
    required this.onDelete,
    super.key,
  });

  final List<TaskListItem> tasks;
  final ValueChanged<int> onTaskTap;
  final ValueChanged<int> onComplete;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskRow(
          title: task.title,
          metadata: task.metadata,
          onTap: () => onTaskTap(index),
          onComplete: () => onComplete(index),
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}
