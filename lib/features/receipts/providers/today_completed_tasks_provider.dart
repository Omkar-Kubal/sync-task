import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../tasks/providers/task_controller.dart';

final todayCompletedTasksProvider = FutureProvider<List<Task>>((ref) {
  return ref
      .watch(taskRepositoryProvider)
      .listCompletedTasksForLocalDay(DateTime.now());
});
