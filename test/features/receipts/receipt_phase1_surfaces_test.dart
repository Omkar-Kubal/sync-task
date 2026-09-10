import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/routing/app_router.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/receipts/domain/receipt_composer_seed.dart';
import 'package:synctasks/features/receipts/providers/receipt_feature_provider.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;
import 'package:synctasks/features/tasks/providers/task_controller.dart';

void main() {
  late AppDatabase db;
  late GoRouter router;

  setUp(() {
    db = AppDatabase.memory();
    router = appRouter();
  });

  tearDown(() async {
    router.dispose();
    await db.close();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    bool receiptFeatureEnabled = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
          receiptFeatureEnabledProvider.overrideWithValue(
            receiptFeatureEnabled,
          ),
        ],
        child: MaterialApp.router(
          theme: buildSyncTasksTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets('feature flag off hides receipt entry points', (tester) async {
    final taskId = await TaskRepository(db).createTask(
      domain.TaskDraft(title: 'Done', scheduledDate: DateTime.now()),
    );
    await TaskRepository(db).completeTask(taskId);

    await pumpApp(tester, receiptFeatureEnabled: false);

    router.go('/today');
    await tester.pumpAndSettle();
    expect(find.textContaining('Create receipt'), findsNothing);

    router.go('/lists');
    await tester.pumpAndSettle();
    expect(find.text('Receipts'), findsNothing);

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('SyncTasks Pro'), findsNothing);
  });

  testWidgets(
    'Today row counts completions from completedAt and opens composer',
    (tester) async {
      final repository = TaskRepository(db);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final overdue = await repository.createTask(
        domain.TaskDraft(
          title: 'Past due but won',
          scheduledDate: DateTime(
            yesterday.year,
            yesterday.month,
            yesterday.day,
          ),
        ),
      );
      await TaskRepository(db).completeTask(overdue);

      await pumpApp(tester);

      router.go('/today');
      await tester.pumpAndSettle();

      expect(find.text('1 completed today · Create receipt →'), findsOneWidget);

      await tester.tap(find.text('1 completed today · Create receipt →'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/receipts/new');
      expect(find.text('Create receipt'), findsOneWidget);
      expect(find.text("Today's wins"), findsWidgets);
      expect(find.text('1 task selected'), findsOneWidget);
      expect(find.text('Past due but won'), findsOneWidget);
    },
  );

  testWidgets('Today receipt row updates after a completed task is restored', (
    tester,
  ) async {
    final repository = TaskRepository(db);
    final taskId = await repository.createTask(
      domain.TaskDraft(title: 'Undo me', scheduledDate: DateTime.now()),
    );
    await TaskRepository(db).completeTask(taskId);

    await pumpApp(tester);

    router.go('/today');
    await tester.pumpAndSettle();
    expect(find.text('1 completed today · Create receipt →'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Lists'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Open Completed list'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Restore task'));
    router.refresh();
    await tester.pumpAndSettle();

    expect(find.textContaining('Create receipt'), findsNothing);
  });

  testWidgets('Lists shows Receipts between Completed and Insights', (
    tester,
  ) async {
    await pumpApp(tester);

    router.go('/lists');
    await tester.pumpAndSettle();

    expect(find.text('Receipts'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Receipts')).dy,
      greaterThan(tester.getTopLeft(find.text('Completed')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Receipts')).dy,
      lessThan(tester.getTopLeft(find.text('Insights')).dy),
    );
  });

  testWidgets('receipt history shell opens empty state and composer shell', (
    tester,
  ) async {
    await pumpApp(tester);

    router.go('/receipts');
    await tester.pumpAndSettle();

    expect(find.text('Receipts'), findsOneWidget);
    expect(find.text('Your completed work, worth keeping.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Create receipt'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/receipts/new');
    expect(find.text('No completed tasks selected'), findsOneWidget);
    expect(
      find.text('Choose completed tasks before generating a receipt.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Generate receipt'),
          )
          .enabled,
      isFalse,
    );
  });

  testWidgets('receipt history back returns to Lists', (tester) async {
    await pumpApp(tester);

    router.go('/receipts');
    await tester.pumpAndSettle();

    expect(find.text('Receipts'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Lists'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/lists');
  });

  testWidgets('Today receipt composer back returns to Today', (tester) async {
    final repository = TaskRepository(db);
    final taskId = await repository.createTask(
      domain.TaskDraft(
        title: 'Back where I started',
        scheduledDate: DateTime.now(),
      ),
    );
    await TaskRepository(db).completeTask(taskId);

    await pumpApp(tester);

    router.go('/today');
    await tester.pumpAndSettle();

    await tester.tap(find.text('1 completed today · Create receipt →'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/receipts/new');

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/today');
  });

  testWidgets(
    'receipt composer back returns to Completed and Insights sources',
    (tester) async {
      await pumpApp(tester);

      router.go(
        '/receipts/new',
        extra: const ReceiptComposerSeed(
          source: ReceiptEntrySource.completedSelection,
          defaultTitle: 'Completed tasks',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/lists/completed',
      );

      router.go(
        '/receipts/new',
        extra: ReceiptComposerSeed(
          source: ReceiptEntrySource.insightsPeriod,
          defaultTitle: "This week's wins",
          periodStart: DateTime(2026, 9, 7),
          periodEndExclusive: DateTime(2026, 9, 14),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/lists/insights');
    },
  );

  testWidgets(
    'Completed selection passes selected completed tasks to composer',
    (tester) async {
      final taskId = await TaskRepository(
        db,
      ).createTask(const domain.TaskDraft(title: 'Signed off'));
      await TaskRepository(db).completeTask(taskId);

      await pumpApp(tester);

      router.go('/lists/completed');
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Signed off'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Create receipt'), findsOneWidget);
      expect(find.bySemanticsLabel('Restore task'), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'Create receipt'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/receipts/new');
      expect(find.text('Completed tasks'), findsWidgets);
      expect(find.text('1 task selected'), findsOneWidget);
      expect(find.text('Signed off'), findsOneWidget);
    },
  );

  testWidgets('Insights entry passes the displayed week range to composer', (
    tester,
  ) async {
    final repository = TaskRepository(db);
    final taskId = await repository.createTask(
      const domain.TaskDraft(title: 'Weekly win'),
    );
    await TaskRepository(db).completeTask(taskId);

    await pumpApp(tester);

    router.go('/lists/insights');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Create receipt'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/receipts/new');
    expect(find.text("This week's wins"), findsWidgets);
    expect(find.text('Weekly win'), findsOneWidget);
  });

  testWidgets('Insights entry handles a week with zero completions honestly', (
    tester,
  ) async {
    await pumpApp(tester);

    router.go('/lists/insights');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Create receipt'));
    await tester.pumpAndSettle();

    expect(find.text('No completions in this period'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Generate receipt'),
          )
          .enabled,
      isFalse,
    );
  });

  testWidgets('Settings Pro row opens an internal-only information sheet', (
    tester,
  ) async {
    await pumpApp(tester);

    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'SyncTasks Pro'));
    await tester.pumpAndSettle();

    expect(find.text('SyncTasks Pro'), findsWidgets);
    expect(find.text('Unlimited receipts'), findsOneWidget);
    expect(find.text('Purchasing arrives in Phase 2.'), findsOneWidget);
    expect(find.text('Restore purchases'), findsNothing);
    expect(find.text('Buy'), findsNothing);
  });
}
