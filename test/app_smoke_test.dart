import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/app.dart';
import 'package:synctasks/core/analytics/analytics_service.dart';

void main() {
  testWidgets('renders SyncTasks app shell', (tester) async {
    await tester.pumpWidget(const SyncTasksApp());

    expect(find.byKey(const Key('app-splash-logo')), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Plan today with less noise'), findsOneWidget);
  });

  testWidgets('tracks the first safe app screen after startup', (tester) async {
    final loggedScreens = <String>[];
    final tracker = AppAnalyticsRouteTracker(
      logScreenView: (screenName) async {
        loggedScreens.add(screenName);
      },
    );

    await tester.pumpWidget(SyncTasksApp(routeTracker: tracker));
    await tester.pump();

    expect(loggedScreens, ['splash']);
  });
}



