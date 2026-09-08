import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/notifications/task_reminder_service.dart';
import '../../../core/widget/widget_data_updater.dart';
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
  return TaskController(
    ref.watch(taskRepositoryProvider),
    ref.watch(taskReminderServiceProvider),
    ref.watch(analyticsServiceProvider),
  );
});

class TaskController {
  const TaskController(
    this._repository, [
    this._reminderService,
    this._analyticsService,
  ]);

  final TaskRepository _repository;
  final TaskReminderService? _reminderService;
  final AnalyticsService? _analyticsService;

  Future<int> create(TaskDraft draft) async {
    final id = await _repository.createTask(draft);
    if (_reminderService != null && draft.reminderTime != null) {
      await _reminderService.reconcileTask(
        taskId: id,
        title: draft.title,
        reminderTime: draft.reminderTime,
        isCompleted: false,
      );
    }
    await _analyticsService?.logEvent(
      'task_created',
      parameters: {
        'has_schedule': draft.scheduledDate != null,
        'has_time': draft.scheduledTime != null,
        'has_reminder': draft.reminderTime != null,
        'has_repeat': draft.recurrenceType != null,
      },
    );
    unawaited(WidgetDataUpdater.update(_repository));
    return id;
  }

  Future<void> updateTitle(int taskId, String title) async {
    await _repository.updateTaskTitle(taskId, title);
    unawaited(WidgetDataUpdater.update(_repository));
  }

  Future<void> updateTask(int taskId, TaskDraft draft) async {
    await _repository.updateTask(taskId, draft);
    if (_reminderService != null) {
      await _reminderService.reconcileTask(
        taskId: taskId,
        title: draft.title,
        reminderTime: draft.reminderTime,
        isCompleted: false,
      );
    }
    unawaited(WidgetDataUpdater.update(_repository));
  }

  Future<TaskSnapshot> complete(int taskId) async {
    final snapshot = await _repository.completeTask(taskId);
    if (_reminderService != null) {
      await _reminderService.cancelTask(taskId);
    }
    await _analyticsService?.logEvent(
      'task_completed',
      parameters: {
        'generated_successor': snapshot.generatedSuccessorId != null,
      },
    );
    unawaited(WidgetDataUpdater.update(_repository));
    return snapshot;
  }

  Future<TaskSnapshot> delete(int taskId) async {
    final snapshot = await _repository.deleteTask(taskId);
    if (_reminderService != null) {
      await _reminderService.cancelTask(taskId);
    }
    unawaited(WidgetDataUpdater.update(_repository));
    return snapshot;
  }

  Future<void> completeTasks(Iterable<int> taskIds) async {
    for (final taskId in taskIds.toSet()) {
      await complete(taskId);
    }
  }

  Future<void> deleteTasks(Iterable<int> taskIds) async {
    for (final taskId in taskIds.toSet()) {
      await delete(taskId);
    }
  }

  Future<void> rescheduleTasks(
    Iterable<int> taskIds,
    DateTime? scheduledDate,
  ) async {
    await _repository.rescheduleTasks(taskIds, scheduledDate);
    unawaited(WidgetDataUpdater.update(_repository));
  }

  Future<void> moveTasksToFolder(Iterable<int> taskIds, int folderId) async {
    await _repository.moveTasksToFolder(taskIds, folderId);
    unawaited(WidgetDataUpdater.update(_repository));
  }

  Future<void> restore(TaskSnapshot snapshot) async {
    await _repository.restoreTask(snapshot);
    unawaited(WidgetDataUpdater.update(_repository));
  }
}


