import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/routing/app_router.dart';
import 'package:sync_task/core/theme/app_theme.dart';

void main() {
  test('app router starts on Today', () {
    final router = appRouter();

    expect(router.routeInformationProvider.value.uri.path, '/today');
    router.dispose();
  });

  testWidgets(
    'secondary pages render inside the shared bottom navigation shell',
    (tester) async {
      final router = appRouter();

      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildSyncTaskTheme(Brightness.light),
          routerConfig: router,
        ),
      );

      router.go('/lists/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.bySemanticsLabel('Today'), findsOneWidget);
      expect(find.bySemanticsLabel('Upcoming'), findsOneWidget);
      expect(find.bySemanticsLabel('Focus'), findsOneWidget);
      expect(find.bySemanticsLabel('Lists'), findsOneWidget);

      router.dispose();
    },
  );
}
