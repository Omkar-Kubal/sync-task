import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../tasks/providers/task_controller.dart';

final taskSearchRefreshProvider = NotifierProvider<TaskSearchRefresh, int>(
  TaskSearchRefresh.new,
);

class TaskSearchRefresh extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

enum TaskSearchFilterKind { all, today, upcoming, completed, folder }

class TaskSearchFilter {
  const TaskSearchFilter.all()
    : kind = TaskSearchFilterKind.all,
      folderId = null;

  const TaskSearchFilter.today()
    : kind = TaskSearchFilterKind.today,
      folderId = null;

  const TaskSearchFilter.upcoming()
    : kind = TaskSearchFilterKind.upcoming,
      folderId = null;

  const TaskSearchFilter.completed()
    : kind = TaskSearchFilterKind.completed,
      folderId = null;

  const TaskSearchFilter.folder(this.folderId)
    : kind = TaskSearchFilterKind.folder;

  final TaskSearchFilterKind kind;
  final int? folderId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TaskSearchFilter &&
            other.kind == kind &&
            other.folderId == folderId;
  }

  @override
  int get hashCode => Object.hash(kind, folderId);
}

class TaskSearchQuery {
  const TaskSearchQuery({required this.query, required this.filter});

  final String query;
  final TaskSearchFilter filter;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TaskSearchQuery &&
            other.query == query &&
            other.filter == filter;
  }

  @override
  int get hashCode => Object.hash(query, filter);
}

final taskSearchProvider = FutureProvider.family<List<Task>, TaskSearchQuery>((
  ref,
  params,
) {
  final query = params.query.trim();
  if (query.isEmpty) {
    return Future.value(const []);
  }
  ref.watch(taskSearchRefreshProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final today = DateTime.now();
  return switch (params.filter.kind) {
    TaskSearchFilterKind.today => repo.searchTasks(
      query,
      isCompleted: false,
      scheduledDate: today,
    ),
    TaskSearchFilterKind.upcoming => repo.searchTasks(
      query,
      isCompleted: false,
      scheduledFrom: today,
    ),
    TaskSearchFilterKind.completed => repo.searchTasks(
      query,
      isCompleted: true,
    ),
    TaskSearchFilterKind.folder => repo.searchTasks(
      query,
      isCompleted: false,
      folderId: params.filter.folderId,
    ),
    TaskSearchFilterKind.all => repo.searchTasks(query),
  };
});


