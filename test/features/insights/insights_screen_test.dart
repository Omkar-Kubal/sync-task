import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/core/theme/app_theme.dart';
import 'package:sync_task/features/insights/domain/insights_summary.dart';
import 'package:sync_task/features/insights/screens/insights_screen.dart';

void main() {
  testWidgets('insights screen renders V1 summary sections', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSyncTaskTheme(Brightness.light),
      home: const InsightsScreen(
        summary: InsightsSummary(
          todayFocusRuns: 3,
          weekFocusRuns: 12,
          todayFocusedDuration: Duration(minutes: 130),
          weekFocusedDuration: Duration(minutes: 525),
          todayCompletedTasks: 5,
          currentStreak: 4,
        ),
      ),
    ));

    for (final text in ['Today', 'This Week', 'Streak', 'Activity', '3 Focus runs', '4 days']) {
      expect(find.text(text), findsOneWidget);
    }
  });
}
