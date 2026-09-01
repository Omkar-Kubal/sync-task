import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/theme/app_theme.dart';
import 'package:synctask/shared/widgets/app_shell.dart';

void main() {
  testWidgets(
    'app shell renders child and exactly four icon-only primary tabs',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSyncTaskTheme(Brightness.light),
          home: AppShell(
            currentIndex: 0,
            onDestinationSelected: (_) {},
            child: const Text('Shell child'),
          ),
        ),
      );

      expect(find.text('Shell child'), findsOneWidget);
      expect(find.bySemanticsLabel('Today'), findsOneWidget);
      expect(find.bySemanticsLabel('Upcoming'), findsOneWidget);
      expect(find.bySemanticsLabel('Focus'), findsOneWidget);
      expect(find.bySemanticsLabel('Lists'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
      expect(find.text('Upcoming'), findsNothing);
      expect(find.text('Focus'), findsNothing);
      expect(find.text('Lists'), findsNothing);
      expect(find.text('Search'), findsNothing);
      expect(find.text('Insights'), findsNothing);
    },
  );
}
