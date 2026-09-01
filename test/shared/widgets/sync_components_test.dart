import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/shared/widgets/sync_bottom_nav.dart';
import 'package:sync_task/shared/widgets/sync_button.dart';
import 'package:sync_task/shared/widgets/sync_fab.dart';
import 'package:sync_task/shared/widgets/sync_header.dart';
import 'package:sync_task/shared/widgets/sync_icon_button.dart';

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

  testWidgets('bottom navigation uses the mockup stadium styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(SyncBottomNav(currentIndex: 0, onTap: (_) {})),
    );

    final navPill = find.byKey(const Key('sync-bottom-nav-pill'));
    expect(navPill, findsOneWidget);

    final navContainer = tester.widget<Container>(navPill);
    final navDecoration = navContainer.decoration! as BoxDecoration;

    expect(tester.getSize(navPill).height, 76);
    expect(navDecoration.color, const Color(0xFFFFFFFF));
    expect(navDecoration.border?.top.width, 3);
    expect(navDecoration.border?.top.color, const Color(0xFF000000));
  });

  testWidgets('primary button and fab expose accessible labels', (
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
  });
}
