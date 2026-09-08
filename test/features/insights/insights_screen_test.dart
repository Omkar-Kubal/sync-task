import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/analytics/analytics_service.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/insights/domain/activity_day.dart';
import 'package:synctasks/features/insights/domain/insights_summary.dart';
import 'package:synctasks/features/insights/screens/insights_screen.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/shared/widgets/sync_grouped_section.dart';

void main() {
  testWidgets('connected insights logs a safe opened analytics event', (
    tester,
  ) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final sink = RecordingAnalyticsSink();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          analyticsServiceProvider.overrideWithValue(AnalyticsService(sink)),
        ],
        child: MaterialApp(
          theme: buildSyncTasksTheme(Brightness.light),
          home: const ConnectedInsightsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(sink.events.map((event) => event.name), ['insights_opened']);
    expect(sink.events.single.parameters, isEmpty);
  });

  testWidgets('insights screen renders V1 summary sections', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: InsightsScreen(
          summary: InsightsSummary(
            todayCompletedTasks: 5,
            weekCompletedTasks: 12,
            currentStreak: 4,
            previousStreak: 3,
            completionTrend: [
              CompletionTrendPoint(
                date: DateTime(2026, 9, 1),
                completedTaskCount: 1,
              ),
              CompletionTrendPoint(
                date: DateTime(2026, 9, 2),
                completedTaskCount: 3,
              ),
            ],
            bestCompletionWeekdayLabel: 'Tuesday',
            bestCompletionWeekdayCount: 6,
            plannedCompletedTasks: 9,
            unplannedCompletedTasks: 3,
            plannedCompletionPercent: 75,
          ),
          activityDays: [
            ActivityDay(
              date: DateTime(2026, 9, 1),
              completedTaskCount: 3,
              intensity: 3,
            ),
          ],
        ),
      ),
    );

    for (final text in [
      'Today',
      'This Week',
      'Streak',
      'Completion Trend',
      'Productive Days',
      'Best Day',
      'Planning',
      '5 tasks completed',
      '12 tasks completed',
      '4 days',
      '75% planned',
      '9 planned · 3 unscheduled',
      'Best on Tuesday',
      '6 completions',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.textContaining('Focus'), findsNothing);
  });

  testWidgets('insights screen presents production cards and empty copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSyncTasksTheme(Brightness.light),
        home: const InsightsScreen(),
      ),
    );

    expect(find.byType(SyncGroupedSection), findsAtLeastNWidgets(5));
    expect(find.text('Complete tasks to unlock trends.'), findsOneWidget);
    expect(find.text('No completion pattern yet'), findsOneWidget);
    expect(
      find.text('Schedule tasks to compare planned vs unscheduled wins.'),
      findsOneWidget,
    );
    expect(find.textContaining('Focus'), findsNothing);
  });
}


