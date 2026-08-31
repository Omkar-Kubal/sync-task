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
    return MaterialApp(theme: buildSyncTaskTheme(Brightness.light), home: Scaffold(body: child));
  }

  testWidgets('header renders large title subtitle and icon action', (tester) async {
    await tester.pumpWidget(wrap(const SyncHeader(
      title: 'Today',
      subtitle: 'Monday, August 31',
      trailing: SyncIconButton(icon: Icons.search, semanticLabel: 'Search'),
    )));

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Monday, August 31'), findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
  });

  testWidgets('bottom navigation has the four required SyncTask tabs', (tester) async {
    await tester.pumpWidget(wrap(SyncBottomNav(currentIndex: 0, onTap: (_) {})));

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('Lists'), findsOneWidget);
  });

  testWidgets('primary button and fab expose accessible labels', (tester) async {
    await tester.pumpWidget(wrap(Column(
      children: [
        SyncButton.primary(label: 'Start Focus', onPressed: () {}),
        SyncFab(onPressed: () {}, semanticLabel: 'Create task'),
      ],
    )));

    expect(find.text('Start Focus'), findsOneWidget);
    expect(find.bySemanticsLabel('Create task'), findsOneWidget);
  });
}
