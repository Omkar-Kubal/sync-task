import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../tasks/providers/task_controller.dart';

final taskSearchProvider = FutureProvider.family<List<Task>, String>((
  ref,
  query,
) {
  if (query.trim().isEmpty) {
    return Future.value(const []);
  }
  return ref.watch(taskRepositoryProvider).searchTasks(query.trim());
});
