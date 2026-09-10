import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/routing/app_router.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/receipts/data/receipt_repository.dart';
import 'package:synctasks/features/receipts/domain/receipt_composer_seed.dart';
import 'package:synctasks/features/receipts/providers/receipt_feature_provider.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
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

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
          receiptFeatureEnabledProvider.overrideWithValue(true),
        ],
        child: MaterialApp.router(
          theme: buildSyncTasksTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );
  }

  Future<int> completedTask(String title, {int? folderId}) async {
    final id = await TaskRepository(
      db,
    ).createTask(domain.TaskDraft(title: title, folderId: folderId));
    await TaskRepository(
      db,
      now: () => DateTime(2026, 9, 10, 10),
    ).completeTask(id);
    return id;
  }

  testWidgets('composer generates a saved receipt and opens detail', (
    tester,
  ) async {
    final workFolder = await FolderRepository(db).createFolder('Work');
    final taskId = await completedTask(
      'Write the migration',
      folderId: workFolder.id,
    );
    await pumpApp(tester);

    router.go(
      '/receipts/new',
      extra: ReceiptComposerSeed(
        source: ReceiptEntrySource.completedSelection,
        defaultTitle: 'Completed tasks',
        selectedTaskIds: [taskId],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 of 3 free receipts left this week'), findsOneWidget);
    expect(find.text('Write the migration'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Migration wins');
    expect(find.text('Work'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Show folder labels'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Generate receipt'));
    await tester.pump();

    expect(find.text('Printing your wins...'), findsOneWidget);
    expect(
      tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset.dy,
      lessThan(0),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      router.routeInformationProvider.value.uri.path,
      startsWith('/receipts/'),
    );
    expect(find.text('Your receipt'), findsOneWidget);
    expect(find.text('Migration wins'), findsOneWidget);
    expect(find.text('Write the migration'), findsOneWidget);
    expect(find.text('Share receipt'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('composer personalises with a drawing before printing receipt', (
    tester,
  ) async {
    final taskId = await completedTask('Sketch the win');
    await pumpApp(tester);

    router.go(
      '/receipts/new',
      extra: ReceiptComposerSeed(
        source: ReceiptEntrySource.completedSelection,
        defaultTitle: 'Completed tasks',
        selectedTaskIds: [taskId],
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Add photo or drawing'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Add photo or drawing'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personalise'), findsOneWidget);
    expect(find.text('Hand drawn'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);

    final canvas = find.byKey(const ValueKey('receipt-drawing-canvas'));
    await tester.drag(canvas, const Offset(80, 40));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Use drawing'));
    await tester.pumpAndSettle();

    expect(find.text('Drawing added'), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-paper-artwork')), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Generate receipt'));
    await tester.pump();
    expect(find.text('Printing your wins...'), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-paper-artwork')), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Your receipt'), findsOneWidget);
    expect(find.text('Sketch the win'), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-paper-artwork')), findsOneWidget);
  });

  testWidgets('history lists generated receipts and reopens detail', (
    tester,
  ) async {
    final taskId = await completedTask('Reopen me');
    await ReceiptRepository(
      db,
      now: () => DateTime(2026, 9, 10, 12),
    ).generateReceipt(
      ReceiptCreateRequest(
        operationId: 'history-op',
        source: ReceiptEntrySource.completedSelection,
        defaultTitle: 'Completed tasks',
        title: 'History wins',
        selectedTaskIds: [taskId],
      ),
    );
    await pumpApp(tester);

    router.go('/receipts');
    await tester.pumpAndSettle();

    expect(find.text('History wins'), findsOneWidget);
    expect(find.textContaining('1 task'), findsOneWidget);

    await tester.tap(find.text('History wins'));
    await tester.pumpAndSettle();

    expect(find.text('Your receipt'), findsOneWidget);
    expect(find.text('Reopen me'), findsOneWidget);
  });

  testWidgets('receipt detail back navigation returns to history', (
    tester,
  ) async {
    final taskId = await completedTask('Back from detail');
    final receipt =
        await ReceiptRepository(
          db,
          now: () => DateTime(2026, 9, 10, 12),
        ).generateReceipt(
          ReceiptCreateRequest(
            operationId: 'detail-back-op',
            source: ReceiptEntrySource.completedSelection,
            defaultTitle: 'Completed tasks',
            title: 'Detail back wins',
            selectedTaskIds: [taskId],
          ),
        );
    await pumpApp(tester);

    router.go('/receipts/${receipt.id}');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back to Receipts'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/receipts');

    router.go('/receipts/${receipt.id}');
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/receipts');
  });

  testWidgets('composer refuses a partial receipt when selection changes', (
    tester,
  ) async {
    final firstId = await TaskRepository(
      db,
    ).createTask(const domain.TaskDraft(title: 'Keep me honest'));
    final firstSnapshot = await TaskRepository(
      db,
      now: () => DateTime(2026, 9, 10, 10),
    ).completeTask(firstId);
    final secondId = await completedTask('Still completed');
    await pumpApp(tester);

    router.go(
      '/receipts/new',
      extra: ReceiptComposerSeed(
        source: ReceiptEntrySource.completedSelection,
        defaultTitle: 'Completed tasks',
        selectedTaskIds: [firstId, secondId],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Keep me honest'), findsOneWidget);
    expect(find.text('Still completed'), findsOneWidget);

    await TaskRepository(db).restoreTask(firstSnapshot);
    await tester.tap(find.widgetWithText(FilledButton, 'Generate receipt'));
    await tester.pumpAndSettle();

    expect(
      find.text('Review the selected tasks before generating.'),
      findsOneWidget,
    );
    expect(await ReceiptRepository(db).listReceipts(), isEmpty);
  });

  testWidgets('composer blocks the fourth free receipt and keeps draft', (
    tester,
  ) async {
    final ids = <int>[];
    for (var i = 0; i < 4; i++) {
      ids.add(await completedTask('Quota task $i'));
    }
    final repository = ReceiptRepository(
      db,
      now: () => DateTime(2026, 9, 10, 12),
    );
    for (var i = 0; i < 3; i++) {
      await repository.generateReceipt(
        ReceiptCreateRequest(
          operationId: 'quota-$i',
          source: ReceiptEntrySource.completedSelection,
          defaultTitle: 'Completed tasks',
          title: 'Used $i',
          selectedTaskIds: [ids[i]],
        ),
      );
    }
    await pumpApp(tester);

    router.go(
      '/receipts/new',
      extra: ReceiptComposerSeed(
        source: ReceiptEntrySource.completedSelection,
        defaultTitle: 'Completed tasks',
        selectedTaskIds: [ids.last],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 of 3 free receipts used'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Still mine');
    await tester.tap(find.widgetWithText(FilledButton, 'Generate receipt'));
    await tester.pumpAndSettle();

    expect(find.text('Weekly receipt limit reached'), findsOneWidget);
    expect(find.textContaining('More free receipts reset'), findsOneWidget);
    expect(find.text('Still mine'), findsWidgets);
    expect(router.routeInformationProvider.value.uri.path, '/receipts/new');
  });
}
