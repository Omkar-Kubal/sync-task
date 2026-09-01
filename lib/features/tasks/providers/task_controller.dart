import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(appDatabaseProvider));
});

final taskControllerProvider = Provider<TaskController>((ref) {
  return TaskController(ref.watch(taskRepositoryProvider));
});

class TaskController {
  const TaskController(this._repository);

  final TaskRepository _repository;

  Future<int> create(TaskDraft draft) {
    return _repository.createTask(draft);
  }

  Future<void> updateTitle(int taskId, String title) {
    return _repository.updateTaskTitle(taskId, title);
  }

  Future<TaskSnapshot> complete(int taskId) {
    return _repository.completeTask(taskId);
  }

  Future<TaskSnapshot> delete(int taskId) {
    return _repository.deleteTask(taskId);
  }

  Future<void> restore(TaskSnapshot snapshot) {
    return _repository.restoreTask(snapshot);
  }
}
