import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock/local_clock_provider.dart';
import '../../tasks/domain/task_due_status.dart';
import '../../tasks/providers/task_controller.dart';

class ListSummaryData {
  const ListSummaryData({
    required this.allCount,
    required this.todayCount,
    required this.upcomingCount,
    required this.completedCount,
    required this.inboxCount,
    required this.remindersCount,
    required this.folderCounts,
  });

  final int allCount;
  final int todayCount;
  final int upcomingCount;
  final int completedCount;
  final int inboxCount;
  final int remindersCount;
  final Map<int, int> folderCounts;
}

final listSummaryProvider = FutureProvider<ListSummaryData>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final allActive = await (db.select(
    db.tasks,
  )..where((t) => t.isCompleted.equals(false))).get();
  final completed = await (db.select(
    db.tasks,
  )..where((t) => t.isCompleted.equals(true))).get();

  final now = ref.watch(localClockProvider);

  final todayCount = allActive
      .where((task) {
        final status = taskDueStatus(
          isCompleted: task.isCompleted,
          scheduledDate: task.scheduledDate,
          scheduledTime: task.scheduledTime,
          now: now,
        );
        return status == TaskDueStatus.today ||
            status == TaskDueStatus.overdue;
      })
      .length;
  final upcomingCount = allActive
      .where((task) {
        final status = taskDueStatus(
          isCompleted: task.isCompleted,
          scheduledDate: task.scheduledDate,
          scheduledTime: task.scheduledTime,
          now: now,
        );
        return status == TaskDueStatus.today ||
            status == TaskDueStatus.upcoming;
      })
      .length;

  final inboxFolder = await (db.select(
    db.folders,
  )..where((f) => f.name.equals('Inbox'))).getSingleOrNull();
  final inboxCount = inboxFolder == null
      ? 0
      : allActive.where((t) => t.folderId == inboxFolder.id).length;
  final remindersCount = allActive.where((t) => t.reminderTime != null).length;

  final folderCounts = <int, int>{};
  for (final task in allActive) {
    folderCounts[task.folderId] = (folderCounts[task.folderId] ?? 0) + 1;
  }

  return ListSummaryData(
    allCount: allActive.length,
    todayCount: todayCount,
    upcomingCount: upcomingCount,
    completedCount: completed.length,
    inboxCount: inboxCount,
    remindersCount: remindersCount,
    folderCounts: folderCounts,
  );
});


