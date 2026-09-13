import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/notifications/notification_service.dart';
import 'package:synctasks/core/notifications/task_reminder_service.dart';
import 'package:synctasks/core/routing/app_router.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/receipts/data/receipt_repository.dart';
import 'package:synctasks/features/receipts/domain/receipt_composer_seed.dart';
import 'package:synctasks/features/receipts/providers/receipt_feature_provider.dart';
import 'package:synctasks/features/receipts/pro/receipt_pro_entitlement.dart';
import 'package:synctasks/features/receipts/services/receipt_photo_capture_service.dart';
import 'package:synctasks/features/receipts/services/receipt_photo_processor.dart';
import 'package:synctasks/features/receipts/services/receipt_printing_feedback.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;
import 'package:synctasks/features/tasks/providers/task_controller.dart';

import 'fake_receipt_pro_billing_service.dart';

void main() {
  late AppDatabase db;
  late GoRouter router;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.memory();
    router = appRouter();
  });

  tearDown(() async {
    router.dispose();
    await db.close();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    ReceiptPhotoCaptureService? photoCaptureService,
    ReceiptPhotoProcessor? photoProcessor,
    ReceiptPrintingFeedback? printingFeedback,
    FakeReceiptProBillingService? receiptProBillingService,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(
            RecordingNotificationScheduler(),
          ),
          receiptFeatureEnabledProvider.overrideWithValue(true),
          if (receiptProBillingService != null)
            receiptProBillingServiceProvider.overrideWithValue(
              receiptProBillingService,
            ),
          if (photoCaptureService != null)
            receiptPhotoCaptureServiceProvider.overrideWithValue(
              photoCaptureService,
            ),
          if (photoProcessor != null)
            receiptPhotoProcessorProvider.overrideWithValue(photoProcessor),
          if (printingFeedback != null)
            receiptPrintingFeedbackProvider.overrideWithValue(printingFeedback),
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
    final printingFeedback = _FakeReceiptPrintingFeedback();
    await pumpApp(tester, printingFeedback: printingFeedback);

    router.go(
      '/receipts/new',
      extra: ReceiptComposerSeed(
        source: ReceiptEntrySource.completedSelection,
        defaultTitle: 'Completed tasks',
        selectedTaskIds: [taskId],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('Create receipt')).style?.fontSize,
      29,
    );
    expect(find.text('0 of 3 free receipts used'), findsOneWidget);
    expect(find.text('Pro unlocks unlimited receipts'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Write the migration'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('receipt-paper-artwork-placeholder')),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'Migration wins');
    expect(find.text('Work'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Show folder labels'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show folder labels'));
    await tester.pumpAndSettle();
    expect(find.text('WORK'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Generate receipt'));
    await tester.pump();

    expect(find.text('Printing your wins...'), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-printer-slot')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('receipt-printing-paper')),
      findsOneWidget,
    );
    expect(
      tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).duration,
      greaterThanOrEqualTo(const Duration(milliseconds: 2400)),
    );
    expect(printingFeedback.starts, 1);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(
      router.routeInformationProvider.value.uri.path,
      startsWith('/receipts/'),
    );
    expect(printingFeedback.stops, 1);
    expect(find.text('Your receipt'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Your receipt')).style?.fontSize, 29);
    expect(find.text('Migration wins'), findsOneWidget);
    expect(find.text('Write the migration'), findsOneWidget);
    expect(find.text('ITEM'), findsOneWidget);
    expect(find.text('DONE'), findsWidgets);
    expect(find.text('TOTAL'), findsOneWidget);
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
    await tester.tap(find.text('Add photo or drawing').first);
    await tester.pumpAndSettle();

    expect(find.text('Personalise'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Personalise')).style?.fontSize, 29);
    expect(find.text('Hand drawn'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);

    final canvas = find.byKey(const ValueKey('receipt-drawing-canvas'));
    expect(tester.getSize(canvas).height, greaterThanOrEqualTo(300));
    final painterBeforeDrawing = tester.widget<CustomPaint>(canvas).painter!;
    await tester.dragFrom(
      tester.getTopLeft(canvas) + const Offset(24, 24),
      const Offset(80, 40),
    );
    await tester.dragFrom(
      tester.getCenter(canvas) - const Offset(70, 20),
      const Offset(140, 60),
    );
    await tester.pump();
    final painterAfterDrawing = tester.widget<CustomPaint>(canvas).painter!;
    expect(painterAfterDrawing.shouldRepaint(painterBeforeDrawing), isTrue);
    await tester.tap(
      find.byKey(const ValueKey('receipt-personalise-generate')),
    );
    await tester.pump();

    expect(find.text('Printing your wins...'), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-paper-artwork')), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Your receipt'), findsOneWidget);
    expect(find.text('Sketch the win'), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-paper-artwork')), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-paper-logo')), findsOneWidget);
    expect(find.text('Drag to play'), findsOneWidget);
  });

  testWidgets('personalise photo tab shows camera capture action', (
    tester,
  ) async {
    final taskId = await completedTask('Photograph the win');
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
    await tester.tap(find.text('Add photo or drawing').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Photo'));
    await tester.pumpAndSettle();

    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Open camera'), findsOneWidget);
    expect(find.text('Photo personalisation comes next.'), findsNothing);
  });

  testWidgets('photo capture generates receipt without returning to composer', (
    tester,
  ) async {
    final taskId = await completedTask('Photograph the win');
    await pumpApp(
      tester,
      photoCaptureService: const _FakeReceiptPhotoCaptureService(
        'D:\\temp\\receipt-photo.jpg',
      ),
      photoProcessor: _FakeReceiptPhotoProcessor(
        'D:\\temp\\receipt-photo_pixelite.png',
      ),
    );

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
    await tester.tap(find.text('Add photo or drawing').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open camera').first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('receipt-personalise-generate')),
    );
    await tester.pump();

    expect(find.text('Printing your wins...'), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-paper-photo')), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Your receipt'), findsOneWidget);
    expect(find.text('Photograph the win'), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-paper-photo')), findsOneWidget);
    final savedReceiptId = (await ReceiptRepository(
      db,
    ).listReceipts()).single.id;
    final savedReceipt = await ReceiptRepository(db).getReceipt(savedReceiptId);
    expect(savedReceipt?.photoPath, 'D:\\temp\\receipt-photo_pixelite.png');
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

  testWidgets('composer shows paywall when weekly receipt quota is exhausted', (
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
    final billingService = FakeReceiptProBillingService(
      autoPurchaseOnBuy: true,
    );
    addTearDown(billingService.close);
    final printingFeedback = _FakeReceiptPrintingFeedback();
    await pumpApp(
      tester,
      receiptProBillingService: billingService,
      printingFeedback: printingFeedback,
    );

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

    expect(
      find.byKey(const ValueKey('receipt-pro-paywall-sheet')),
      findsOneWidget,
    );
    expect(find.text('Create receipt'), findsOneWidget);
    expect(find.text('Unlimited receipts'), findsWidgets);
    expect(find.text('Keep a record of your completed work.'), findsOneWidget);
    expect(
      find.textContaining('Free receipts reset Monday, 14 Sept.'),
      findsOneWidget,
    );
    expect(find.text('Unlock for ₹199'), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
    expect(
      find.text('Saved receipts and all task features stay free.'),
      findsOneWidget,
    );
    expect(find.text('Printing your wins...'), findsNothing);
    expect(await ReceiptRepository(db).listReceipts(), hasLength(3));

    await tester.tap(find.widgetWithText(FilledButton, 'Unlock for ₹199'));
    await tester.pump();
    await tester.pump();

    expect(billingService.buyCount, 1);
    expect(find.text('Printing your wins...'), findsOneWidget);
    expect(printingFeedback.starts, 1);
    expect(await ReceiptRepository(db).listReceipts(), hasLength(4));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Your receipt'), findsOneWidget);
  });
}

class _FakeReceiptPhotoCaptureService implements ReceiptPhotoCaptureService {
  const _FakeReceiptPhotoCaptureService(this.path);

  final String? path;

  @override
  Future<String?> capturePhoto() async => path;
}

class _FakeReceiptPhotoProcessor implements ReceiptPhotoProcessor {
  _FakeReceiptPhotoProcessor(this.path);

  final String path;
  final sourcePaths = <String>[];

  @override
  Future<String> processPhoto(String sourcePath) async {
    sourcePaths.add(sourcePath);
    return path;
  }
}

class _FakeReceiptPrintingFeedback implements ReceiptPrintingFeedback {
  var starts = 0;
  var stops = 0;

  @override
  ReceiptPrintingFeedbackHandle start() {
    starts++;
    return _FakeReceiptPrintingFeedbackHandle(() => stops++);
  }
}

class _FakeReceiptPrintingFeedbackHandle
    implements ReceiptPrintingFeedbackHandle {
  _FakeReceiptPrintingFeedbackHandle(this.onStop);

  final VoidCallback onStop;
  var stopped = false;

  @override
  void stop() {
    if (stopped) {
      return;
    }
    stopped = true;
    onStop();
  }
}
