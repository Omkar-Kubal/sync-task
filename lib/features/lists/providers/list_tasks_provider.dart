import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../tasks/providers/completed_tasks_provider.dart';
import '../../tasks/providers/task_controller.dart';
import '../../tasks/providers/today_tasks_provider.dart';
import '../../tasks/providers/upcoming_tasks_provider.dart';
import 'list_summary_provider.dart';

final allTasksProvider = FutureProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).listAllActiveTasks();
});

final reminderTasksProvider = FutureProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).listReminderTasks();
});

final folderTasksProvider = FutureProvider.family<List<Task>, int>((
  ref,
  folderId,
) {
  return ref.watch(taskRepositoryProvider).listFolderTasks(folderId);
});

void invalidateTaskListProviders(
  WidgetRef ref, {
  Iterable<int> folderIds = const [],
}) {
  ref.invalidate(allTasksProvider);
  ref.invalidate(reminderTasksProvider);
  ref.invalidate(completedTasksProvider);
  ref.invalidate(todayTasksProvider);
  ref.invalidate(upcomingTasksProvider);
  ref.invalidate(listSummaryProvider);
  for (final folderId in folderIds.toSet()) {
    ref.invalidate(folderTasksProvider(folderId));
  }
}


