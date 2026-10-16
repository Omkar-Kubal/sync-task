import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/clock/local_clock_provider.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/lists/providers/list_summary_provider.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';

void main() {
  test('Today and Upcoming counts share minute-based due status', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final now = DateTime(2026, 10, 8, 10, 0, 30);
    final today = DateTime(2026, 10, 8);
    final repository = TaskRepository(db, now: () => now);

    await repository.createTask(
      TaskDraft(
        title: 'Past minute',
        scheduledDate: today,
        scheduledTime: DateTime(2026, 10, 8, 9, 59),
      ),
    );
    await repository.createTask(
      TaskDraft(title: 'Date only', scheduledDate: today),
    );
    await repository.createTask(
      TaskDraft(
        title: 'Current minute',
        scheduledDate: today,
        scheduledTime: DateTime(2026, 10, 8, 10, 0),
      ),
    );
    await repository.createTask(
      TaskDraft(title: 'Future date', scheduledDate: DateTime(2026, 10, 9)),
    );
    await repository.createTask(const TaskDraft(title: 'No date'));

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        localClockProvider.overrideWithValue(now),
      ],
    );
    addTearDown(container.dispose);

    final summary = await container.read(listSummaryProvider.future);
    expect(summary.allCount, 5);
    expect(summary.todayCount, 3);
    expect(summary.upcomingCount, 3);
  });
}
