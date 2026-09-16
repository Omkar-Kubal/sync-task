import 'package:synctasks/shared/icons/list_filter_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/shared/services/sync_sounds.dart';
import 'package:synctasks/shared/widgets/sync_bottom_nav.dart';
import 'package:synctasks/shared/widgets/sync_button.dart';
import 'package:synctasks/shared/widgets/sync_empty_state.dart';
import 'package:synctasks/shared/widgets/sync_fab.dart';
import 'package:synctasks/shared/widgets/sync_grouped_section.dart';
import 'package:synctasks/shared/widgets/sync_header.dart';
import 'package:synctasks/shared/widgets/sync_icon_button.dart';

void main() {
  tearDown(SyncSounds.resetForTesting);

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: buildSyncTasksTheme(Brightness.light),
      home: Scaffold(body: child),
    );
  }

  testWidgets('header renders large title subtitle and icon action', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const SyncHeader(
          title: 'Today',
          subtitle: 'Monday, August 31',
          trailing: SyncIconButton(icon: Icons.search, semanticLabel: 'Search'),
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Today'));
    expect(title.style?.fontSize, 29);
    expect(find.text('Monday, August 31'), findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
  });

  testWidgets('header can use production compact spacing', (tester) async {
    await tester.pumpWidget(
      wrap(
        const SyncHeader(
          title: 'Lists',
          compact: true,
          trailing: SyncIconButton(icon: Icons.search, semanticLabel: 'Search'),
        ),
      ),
    );

    expect(tester.getTopLeft(find.text('Lists')).dx, 20);
    expect(tester.getTopLeft(find.text('Lists')).dy, 18);
    expect(tester.getSize(find.bySemanticsLabel('Search')), const Size(44, 44));
  });

  testWidgets('bottom navigation exposes Today and Lists icon-only tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 0, onTap: (_) {})),
    );

    expect(find.bySemanticsLabel('Today'), findsOneWidget);
    expect(find.bySemanticsLabel('Upcoming'), findsNothing);
    expect(find.bySemanticsLabel('Focus'), findsNothing);
    expect(find.bySemanticsLabel('Lists'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    expect(find.text('Upcoming'), findsNothing);
    expect(find.text('Focus'), findsNothing);
    expect(find.text('Lists'), findsNothing);
  });

  testWidgets('bottom navigation uses the shared task-list icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 0, onTap: (_) {})),
    );

    expect(find.byType(ListFilterIcon), findsOneWidget);
    expect(find.byIcon(Icons.format_list_bulleted_rounded), findsNothing);
  });

  testWidgets('bottom navigation emits haptics when Lists is tapped', (
    tester,
  ) async {
    final haptics = _captureHaptics(tester);
    final sounds = _FakeSyncSoundAssetPlayer();
    SyncSounds.configureForTesting(player: sounds);
    var selectedIndex = 0;
    await tester.pumpWidget(
      wrap(
        SyncBottomNav(
          currentIndex: selectedIndex,
          onTap: (index) => selectedIndex = index,
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Lists'));

    expect(selectedIndex, 1);
    expect(haptics, contains('HapticFeedbackType.selectionClick'));
    expect(sounds.plays, ['sounds/select.wav']);
  });

  testWidgets(
    'bottom navigation fills the selected today date tile with today',
    (tester) async {
      await tester.pumpWidget(
        wrap(SyncBottomNav(currentIndex: 0, onTap: (_) {})),
      );

      final selectedTile = find.byKey(const Key('sync-bottom-nav-today-tile'));
      final today = DateTime.now().day.toString();
      expect(selectedTile, findsOneWidget);

      final selectedContainer = tester.widget<Container>(selectedTile);
      final selectedDecoration = selectedContainer.decoration! as BoxDecoration;

      expect(selectedDecoration.color, const Color(0xFF000000));
      expect(
        tester
            .widget<Text>(
              find.descendant(of: selectedTile, matching: find.text(today)),
            )
            .style
            ?.color,
        const Color(0xFFFFFFFF),
      );
    },
  );

  testWidgets('bottom navigation uses tight translucent borderless styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 0, onTap: (_) {})),
    );

    final navPill = find.byKey(const Key('sync-bottom-nav-pill'));
    expect(navPill, findsOneWidget);

    final navContainer = tester.widget<Container>(navPill);
    final navDecoration = navContainer.decoration! as BoxDecoration;
    final todayTile = find.byKey(const Key('sync-bottom-nav-today-tile'));
    final listIcon = tester.widget<ListFilterIcon>(find.byType(ListFilterIcon));

    expect(tester.getSize(navPill), const Size(184, 44));
    expect(tester.getSize(todayTile), const Size(28, 28));
    expect(listIcon.size, 22);
    expect(navDecoration.color, const Color(0xD9FFFFFF));
    expect(navDecoration.border, isNull);
    expect(navDecoration.borderRadius, BorderRadius.circular(24));
  });

  testWidgets('bottom navigation highlights Lists tile when selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 1, onTap: (_) {})),
    );

    final listsTile = find.byKey(const Key('sync-bottom-nav-lists-tile'));
    expect(listsTile, findsOneWidget);

    final tileContainer = tester.widget<Container>(listsTile);
    final decoration = tileContainer.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFF000000));
  });

  testWidgets('bottom navigation stays responsive when Lists is selected', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 1, onTap: (_) {})),
    );

    final navPill = find.byKey(const Key('sync-bottom-nav-pill'));
    final left = tester.getTopLeft(navPill).dx;
    final right = tester.getTopRight(navPill).dx;

    expect(tester.getSize(navPill).width, lessThanOrEqualTo(220));
    expect(left, closeTo((430 - tester.getSize(navPill).width) / 2, 0.1));
    expect(right, lessThanOrEqualTo(430 - 12));
  });

  testWidgets('primary button and compact fab expose accessible labels', (
    tester,
  ) async {
    final sounds = _FakeSyncSoundAssetPlayer();
    SyncSounds.configureForTesting(player: sounds);
    var created = false;
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            SyncButton.primary(label: 'Save', onPressed: () {}),
            SyncFab(
              onPressed: () => created = true,
              semanticLabel: 'Create task',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    expect(find.bySemanticsLabel('Create task'), findsOneWidget);
    expect(
      tester.getSize(find.byType(FloatingActionButton)),
      const Size(56, 56),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    final buttonShape = button.style!.shape!.resolve({});
    expect(
      (buttonShape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(18),
    );

    await tester.tap(find.bySemanticsLabel('Create task'));

    expect(created, isTrue);
    expect(sounds.plays, ['sounds/action.wav']);
  });

  testWidgets('primary button exposes disabled and loading states', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            SyncButton.primary(label: 'Save', onPressed: null),
            SyncButton.primary(
              label: 'Saving',
              onPressed: null,
              isLoading: true,
            ),
          ],
        ),
      ),
    );

    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .enabled,
      isFalse,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Saving'), findsNothing);
  });

  testWidgets(
    'empty state renders production copy optional action and tap target',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          SyncEmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: "You're clear for today.",
            message: 'Create a task whenever something pops up.',
            actionLabel: 'Create new task',
            onAction: () => tapped = true,
          ),
        ),
      );

      expect(find.text("You're clear for today."), findsOneWidget);
      expect(
        find.text('Create a task whenever something pops up.'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.widgetWithText(FilledButton, 'Create new task')),
        const Size(160, 40),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Create new task'));
      expect(tapped, isTrue);
    },
  );

  testWidgets('grouped sections use rounded borderless app surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const SyncGroupedSection(children: [ListTile(title: Text('Inbox'))]),
      ),
    );

    final section = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox).first,
    );
    final decoration = section.decoration as BoxDecoration;

    expect(decoration.borderRadius, BorderRadius.circular(24));
    expect(decoration.border, isNull);
    expect(decoration.boxShadow, isNotNull);
    expect(decoration.boxShadow!.single.blurRadius, greaterThanOrEqualTo(16));
    expect(find.byType(Divider), findsNothing);
  });
}

List<Object?> _captureHaptics(WidgetTester tester) {
  final calls = <Object?>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add(call.arguments);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

class _FakeSyncSoundAssetPlayer implements SyncSoundAssetPlayer {
  final plays = <String>[];

  @override
  Future<void> playAsset(String assetPath, {required double volume}) async {
    plays.add(assetPath);
  }

  @override
  SyncSoundLoopHandle startLoopAsset(
    String assetPath, {
    required double volume,
  }) {
    return _FakeSyncSoundLoopHandle();
  }
}

class _FakeSyncSoundLoopHandle implements SyncSoundLoopHandle {
  @override
  void stop() {}
}
