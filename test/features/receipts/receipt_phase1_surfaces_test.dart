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
import 'package:synctasks/features/receipts/domain/receipt_composer_seed.dart';
import 'package:synctasks/features/receipts/providers/receipt_feature_provider.dart';
import 'package:synctasks/features/receipts/pro/receipt_pro_entitlement.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart' as domain;
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/shared/icons/sync_icons.dart';

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
    bool receiptFeatureEnabled = true,
    FakeReceiptProBillingService? receiptProBillingService,
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
          if (receiptProBillingService != null)
            receiptProBillingServiceProvider.overrideWithValue(
              receiptProBillingService,
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

  testWidgets('receipt history create preselects completed tasks', (
    tester,
  ) async {
    final taskId = await TaskRepository(
      db,
    ).createTask(const domain.TaskDraft(title: 'History-ready win'));
    await TaskRepository(db).completeTask(taskId);
    await pumpApp(tester);

    router.go('/receipts');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create receipt'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/receipts/new');
    expect(find.text('1 task selected'), findsOneWidget);
    expect(find.text('History-ready win'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Generate receipt'),
          )
          .enabled,
      isTrue,
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
      expect(find.text('Pro unlocks unlimited receipts'), findsOneWidget);
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

  testWidgets('Settings Pro row opens the receipt paywall bottom sheet', (
    tester,
  ) async {
    final billingService = FakeReceiptProBillingService();
    addTearDown(billingService.close);
    await pumpApp(tester, receiptProBillingService: billingService);

    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'SyncTasks Pro'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('receipt-pro-paywall-sheet')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('receipt-pro-brand-title')),
      findsOneWidget,
    );
    final logoImage = find.descendant(
      of: find.byKey(const ValueKey('receipt-pro-logo-mark')),
      matching: find.byType(Image),
    );
    expect(logoImage, findsOneWidget);
    expect(
      (tester.widget<Image>(logoImage).image as AssetImage).assetName,
      'assets/images/logo-whitebackground.png',
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('receipt-pro-logo-mark')),
        matching: find.byIcon(SyncIcons.premium),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('receipt-pro-badge')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('receipt-pro-badge')),
        matching: find.byIcon(SyncIcons.premium),
      ),
      findsOneWidget,
    );
    final badgePremiumIcon = find.descendant(
      of: find.byKey(const ValueKey('receipt-pro-badge')),
      matching: find.byIcon(SyncIcons.premium),
    );
    expect(
      tester.widget<Icon>(badgePremiumIcon).color,
      SyncIcons.premiumSilverOnFilled(tester.element(badgePremiumIcon)),
    );
    expect(
      find.byKey(const ValueKey('receipt-pro-lifetime-option-card')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('receipt-pro-lifetime-option-card')),
        matching: find.byIcon(SyncIcons.premium),
      ),
      findsOneWidget,
    );
    final lifetimePremiumIcon = find.descendant(
      of: find.byKey(const ValueKey('receipt-pro-lifetime-option-card')),
      matching: find.byIcon(SyncIcons.premium),
    );
    expect(
      tester.widget<Icon>(lifetimePremiumIcon).color,
      SyncIcons.premiumSilverOnFilled(tester.element(lifetimePremiumIcon)),
    );
    expect(find.text('Unlimited receipts'), findsWidgets);
    expect(
      tester.getTopLeft(find.text('3 free receipts weekly')).dy,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('receipt-pro-lifetime-option-card')),
            )
            .dy,
      ),
    );
    expect(find.text('Lifetime'), findsOneWidget);
    expect(find.text('One-time receipt upgrade'), findsOneWidget);
    expect(find.text('Unlock for ₹199'), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
    expect(find.text('Purchasing arrives in Phase 2.'), findsNothing);
  });

  testWidgets('unavailable receipt paywall does not show a fallback price', (
    tester,
  ) async {
    final billingService = FakeReceiptProBillingService(available: false);
    addTearDown(billingService.close);
    await pumpApp(tester, receiptProBillingService: billingService);

    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'SyncTasks Pro'));
    await tester.pumpAndSettle();

    expect(find.text('Unlock for ₹199'), findsNothing);
    expect(find.text('₹199'), findsNothing);
    expect(find.text('Price unavailable'), findsWidgets);
    final textStyle = tester
        .widget<Text>(find.text('Price unavailable').last)
        .style;
    expect(textStyle?.color, isNotNull);
    expect(textStyle!.color!.computeLuminance(), greaterThan(0.45));
  });

  testWidgets('receipt paywall uses shared SyncTasks component scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final billingService = FakeReceiptProBillingService();
    addTearDown(billingService.close);
    await pumpApp(tester, receiptProBillingService: billingService);

    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'SyncTasks Pro'));
    await tester.pumpAndSettle();

    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester
          .getSize(find.byKey(const ValueKey('receipt-pro-paywall-sheet')))
          .height,
      lessThanOrEqualTo(screenHeight * 0.85),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('receipt-pro-paywall-sheet')))
          .dy,
      greaterThanOrEqualTo(screenHeight * 0.15),
    );
    final closeButton = find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == 'Close',
    );
    expect(tester.getSize(closeButton), const Size(46, 46));
    expect(
      tester.widget<IconButton>(closeButton).style?.side?.resolve({}),
      BorderSide.none,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('receipt-pro-logo-mark'))),
      const Size(40, 40),
    );
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('receipt-pro-lifetime-option-card')),
          )
          .height,
      56,
    );
    final featureTitle = tester.widget<Text>(
      find.text('3 free receipts weekly'),
    );
    expect(featureTitle.style?.fontSize, 15);
    expect(featureTitle.style?.fontWeight, FontWeight.w500);
    final featureBody = tester.widget<Text>(
      find.text(
        'Pro unlocks unlimited receipt generation whenever you need it.',
      ),
    );
    expect(featureBody.style?.fontSize, 13);
    expect(featureBody.style?.fontWeight, FontWeight.w500);
    final unlockButtonSize = tester.getSize(
      find.widgetWithText(FilledButton, 'Unlock for ₹199'),
    );
    expect(unlockButtonSize.height, 56);
    expect(unlockButtonSize.width, greaterThanOrEqualTo(320));
    expect(
      tester
          .getBottomLeft(find.widgetWithText(TextButton, 'Restore purchases'))
          .dy,
      lessThanOrEqualTo(
        tester
            .getBottomLeft(
              find.byKey(const ValueKey('receipt-pro-paywall-sheet')),
            )
            .dy,
      ),
    );
  });

  testWidgets('receipt paywall uses one cohesive app-style value panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final billingService = FakeReceiptProBillingService();
    addTearDown(billingService.close);
    await pumpApp(tester, receiptProBillingService: billingService);

    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'SyncTasks Pro'));
    await tester.pumpAndSettle();

    final valuePanel = find.byKey(const ValueKey('receipt-pro-value-panel'));
    expect(valuePanel, findsOneWidget);
    expect(
      find.descendant(
        of: valuePanel,
        matching: find.text('3 free receipts weekly'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: valuePanel,
        matching: find.text('Unlimited receipts'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: valuePanel,
        matching: find.text('Your data stays safe'),
      ),
      findsOneWidget,
    );

    final benefitsBottom = tester.getBottomLeft(valuePanel).dy;
    final planTop = tester
        .getTopLeft(
          find.byKey(const ValueKey('receipt-pro-lifetime-option-card')),
        )
        .dy;
    expect(planTop - benefitsBottom, lessThanOrEqualTo(32));
  });

  testWidgets('receipt paywall sheet surface has the shared top shadow', (
    tester,
  ) async {
    final billingService = FakeReceiptProBillingService();
    addTearDown(billingService.close);
    await pumpApp(tester, receiptProBillingService: billingService);

    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'SyncTasks Pro'));
    await tester.pumpAndSettle();

    final surface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('receipt-pro-paywall-surface')),
    );
    final decoration = surface.decoration as BoxDecoration;
    final shadow = decoration.boxShadow!.single;

    expect(shadow.blurRadius, greaterThanOrEqualTo(28));
    expect(shadow.offset.dy, lessThanOrEqualTo(-6));
    expect(shadow.color.a, greaterThanOrEqualTo(0.10));
  });
}
