import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import 'task_controller.dart';

final completedTasksProvider = FutureProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).listCompletedTasks();
});
