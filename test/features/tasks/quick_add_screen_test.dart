import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/settings/data/settings_repository.dart';
import 'package:synctasks/features/settings/domain/app_settings.dart';
import 'package:synctasks/features/settings/providers/settings_controller.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/features/tasks/providers/today_tasks_provider.dart';
import 'package:synctasks/features/tasks/screens/quick_add_screen.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settingsRepository;
  late RecordingNotificationScheduler notifications;

  setUp(() {
    db = AppDatabase.memory();
    settingsRepository = SettingsRepository.memory();
    notifications = RecordingNotificationScheduler();
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        taskRepositoryProvider.overrideWithValue(
          TaskRepository(db, now: () => DateTime(2026, 9, 7, 10)),
        ),
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: child,
      ),
    );
  }

  testWidgets(
    'quick add uses default folder, parses date text, and shows success before closing',
    (tester) async {
      final work = await FolderRepository(db).createFolder('Work');
      await settingsRepository.save(AppSettings(defaultFolderId: work.id));
      final platformCalls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          platformCalls.add(call.method);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(
        wrap(QuickAddScreen(now: () => DateTime(2026, 9, 7, 10))),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(QuickAddScreen)),
        listen: false,
      );
      expect(await container.read(todayTasksProvider.future), isEmpty);

      expect(find.widgetWithText(OutlinedButton, 'Work'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Draft launch');
      await tester.tap(find.bySemanticsLabel('Submit task'));
      await tester.pump();

      expect(find.text('Added'), findsOneWidget);
      expect(platformCalls, isNot(contains('SystemNavigator.pop')));

      await tester.pump(const Duration(milliseconds: 700));

      expect(platformCalls, contains('SystemNavigator.pop'));
      final tasks = await db.select(db.tasks).get();
      expect(tasks, hasLength(1));
      expect(tasks.single.title, 'Draft launch');
      expect(tasks.single.folderId, work.id);
      expect(tasks.single.scheduledDate, DateTime(2026, 9, 7));
      expect(await container.read(todayTasksProvider.future), hasLength(1));
    },
  );
}
