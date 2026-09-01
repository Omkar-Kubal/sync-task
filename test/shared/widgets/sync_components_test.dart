import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/shared/widgets/sync_bottom_nav.dart';
import 'package:synctask/shared/widgets/sync_button.dart';
import 'package:synctask/shared/widgets/sync_fab.dart';
import 'package:synctask/shared/widgets/sync_header.dart';
import 'package:synctask/shared/widgets/sync_icon_button.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: buildSyncTaskTheme(Brightness.light),
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
    expect(find.text('Monday, August 31'), findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
  });

  testWidgets('bottom navigation exposes four icon-only SyncTask tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 0, onTap: (_) {})),
    );

    expect(find.bySemanticsLabel('Today'), findsOneWidget);
    expect(find.bySemanticsLabel('Upcoming'), findsOneWidget);
    expect(find.bySemanticsLabel('Focus'), findsOneWidget);
    expect(find.bySemanticsLabel('Lists'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    expect(find.text('Upcoming'), findsNothing);
    expect(find.text('Focus'), findsNothing);
    expect(find.text('Lists'), findsNothing);
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

  testWidgets('bottom navigation uses the logo asset for Focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 2, onTap: (_) {})),
    );

    final logo = tester.widget<Image>(
      find.byKey(const Key('sync-bottom-nav-focus-logo')),
    );
    final image = logo.image as AssetImage;

    expect(image.assetName, 'assets/images/logo.png');
  });

  testWidgets('bottom navigation uses translucent borderless Android styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 0, onTap: (_) {})),
    );

    final navPill = find.byKey(const Key('sync-bottom-nav-pill'));
    expect(navPill, findsOneWidget);

    final navContainer = tester.widget<Container>(navPill);
    final navDecoration = navContainer.decoration! as BoxDecoration;

    expect(tester.getSize(navPill).height, 52);
    expect(navDecoration.color, const Color(0xD9FFFFFF));
    expect(navDecoration.border, isNull);
  });

  testWidgets('bottom navigation stays responsive when Upcoming is selected', (
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

    expect(tester.getSize(navPill).width, lessThanOrEqualTo(360));
    expect(left, closeTo((430 - tester.getSize(navPill).width) / 2, 0.1));
    expect(right, lessThanOrEqualTo(430 - 16));
  });

  testWidgets('primary button and compact fab expose accessible labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            SyncButton.primary(label: 'Start Focus', onPressed: () {}),
            SyncFab(onPressed: () {}, semanticLabel: 'Create task'),
          ],
        ),
      ),
    );

    expect(find.text('Start Focus'), findsOneWidget);
    expect(find.bySemanticsLabel('Create task'), findsOneWidget);
    expect(
      tester.getSize(find.byType(FloatingActionButton)),
      const Size(48, 48),
    );
  });
}
