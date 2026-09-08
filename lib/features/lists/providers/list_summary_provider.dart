import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);

  final todayCount = allActive
      .where((t) => t.scheduledDate == todayDate)
      .length;
  final upcomingCount = allActive
      .where(
        (t) => t.scheduledDate != null && !t.scheduledDate!.isBefore(todayDate),
      )
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


