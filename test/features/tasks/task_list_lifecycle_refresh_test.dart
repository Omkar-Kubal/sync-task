import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/features/tasks/screens/today_screen.dart';
import 'package:synctasks/features/tasks/widgets/task_list_lifecycle_refresh.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('today refreshes tasks created externally when app resumes', (
    tester,
  ) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
        ],
        child: MaterialApp(
          theme: buildSyncTasksTheme(Brightness.light),
          home: const TaskListLifecycleRefresh(child: TodayScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Widget task'), findsNothing);
    expect(find.text("You're clear for today."), findsOneWidget);

    await TaskRepository(db, now: () => todayDate).createTask(
      domain.TaskDraft(title: 'Widget task', scheduledDate: todayDate),
    );
    await tester.pumpAndSettle();

    expect(find.text('Widget task'), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Widget task'), findsOneWidget);
  });
}


