import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../receipts/domain/receipt_composer_seed.dart';
import '../../receipts/providers/receipt_feature_provider.dart';
import '../../tasks/providers/task_controller.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/widgets/sync_empty_state.dart';
import '../../../shared/widgets/sync_grouped_section.dart';
import '../../../shared/widgets/sync_header.dart';
import '../domain/activity_day.dart';
import '../domain/insights_summary.dart';
import '../providers/activity_grid_provider.dart';
import '../providers/insights_provider.dart';
import '../widgets/activity_grid.dart';

class ConnectedInsightsScreen extends ConsumerStatefulWidget {
  const ConnectedInsightsScreen({super.key});

  @override
  ConsumerState<ConnectedInsightsScreen> createState() =>
      _ConnectedInsightsScreenState();
}

class _ConnectedInsightsScreenState
    extends ConsumerState<ConnectedInsightsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(analyticsServiceProvider).logEvent('insights_opened'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final summaryValue = ref.watch(insightsProvider);
    final activityValue = ref.watch(activityGridProvider(year));
    final receiptFeatureEnabled = ref.watch(receiptFeatureEnabledProvider);

    return summaryValue.when(
      data: (summary) => InsightsScreen(
        summary: summary,
        activityDays: activityValue.value ?? const <ActivityDay>[],
        onCreateReceipt: receiptFeatureEnabled
            ? () => _openReceiptComposer(context)
            : null,
      ),
      loading: () => const InsightsScreen(),
      error: (error, stackTrace) => const _InsightsErrorScreen(),
    );
  }

  Future<void> _openReceiptComposer(BuildContext context) async {
    final today = _dateOnly(DateTime.now());
    final weekStart = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    final weekEnd = weekStart.add(const Duration(days: 7));
    final tasks = await ref
        .read(taskRepositoryProvider)
        .listCompletedTasksInRange(weekStart, weekEnd);
    if (!context.mounted) {
      return;
    }
    context.go(
      '/receipts/new',
      extra: ReceiptComposerSeed(
        source: ReceiptEntrySource.insightsPeriod,
        defaultTitle: "This week's wins",
        selectedTaskIds: tasks.map((task) => task.id).toList(),
        periodStart: weekStart,
        periodEndExclusive: weekEnd,
      ),
    );
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    this.summary = const InsightsSummary(
      todayCompletedTasks: 0,
      weekCompletedTasks: 0,
      currentStreak: 0,
    ),
    this.activityDays = const <ActivityDay>[],
    this.onCreateReceipt,
    super.key,
  });

  final InsightsSummary summary;
  final List<ActivityDay> activityDays;
  final VoidCallback? onCreateReceipt;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SyncHeader(title: 'Insights', compact: true),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: SyncGroupedSection(
                  dividerIndent: 0,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Today',
                              value: '${summary.todayCompletedTasks}',
                              caption: _taskCountLabel(
                                summary.todayCompletedTasks,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              label: 'This Week',
                              value: '${summary.weekCompletedTasks}',
                              caption: _taskCountLabel(
                                summary.weekCompletedTasks,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(
                              label: 'Streak',
                              value: '${summary.currentStreak}',
                              caption: _dayCountLabel(summary.currentStreak),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (onCreateReceipt != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: OutlinedButton.icon(
                    onPressed: onCreateReceipt,
                    icon: Icon(SyncIcons.receipt, size: 18),
                    label: const Text('Create receipt'),
                  ),
                ),
              _InsightSection(
                title: 'Completion Trend',
                child: _CompletionTrend(points: summary.completionTrend),
              ),
              _InsightSection(
                title: 'Productive Days',
                child: activityDays.isEmpty
                    ? const _SectionEmptyText(
                        'Your activity heatmap will appear here.',
                      )
                    : ActivityGrid(days: activityDays),
              ),
              _InsightSection(
                title: 'Best Day',
                child: _BestDay(summary: summary),
              ),
              _InsightSection(
                title: 'Planning',
                child: _PlanningBreakdown(summary: summary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightsErrorScreen extends StatelessWidget {
  const _InsightsErrorScreen();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Scaffold(
      backgroundColor: colors.scaffold,
      body: const SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SyncHeader(title: 'Insights', compact: true),
            Expanded(
              child: SyncEmptyState(
                icon: SyncIcons.insights,
                title: 'Could not load insights',
                message: 'Try again in a moment.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightSection extends StatelessWidget {
  const _InsightSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: SyncGroupedSection(
        dividerIndent: 16,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSecondary.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.divider.withValues(alpha: 0.72)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value $caption',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                height: 1.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionTrend extends StatelessWidget {
  const _CompletionTrend({required this.points});

  final List<CompletionTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty ||
        points.every((point) => point.completedTaskCount == 0)) {
      return const _SectionEmptyText('Complete tasks to unlock trends.');
    }

    final maxCount = points
        .map((point) => point.completedTaskCount)
        .fold<int>(1, (max, count) => count > max ? count : max);
    return SizedBox(
      height: 124,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final point in points) ...[
            Expanded(
              child: _TrendBar(
                label: DateFormat.E().format(point.date),
                count: point.completedTaskCount,
                maxCount: maxCount,
              ),
            ),
            if (point != points.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({
    required this.label,
    required this.count,
    required this.maxCount,
  });

  final String label;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final height = 16 + (count / maxCount * 58);
    return Semantics(
      label: '$label: $count completed tasks',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$count',
            style: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 18,
            height: height,
            decoration: BoxDecoration(
              color: count == 0
                  ? colors.surfaceSecondary
                  : colors.controlPrimary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _BestDay extends StatelessWidget {
  const _BestDay({required this.summary});

  final InsightsSummary summary;

  @override
  Widget build(BuildContext context) {
    final hasPattern = summary.bestCompletionWeekdayCount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryLine(
          hasPattern
              ? 'Best on ${summary.bestCompletionWeekdayLabel}'
              : 'No completion pattern yet',
        ),
        if (hasPattern) ...[
          const SizedBox(height: 6),
          _SecondaryLine(
            '${summary.bestCompletionWeekdayCount} ${summary.bestCompletionWeekdayCount == 1 ? 'completion' : 'completions'}',
          ),
        ],
      ],
    );
  }
}

class _PlanningBreakdown extends StatelessWidget {
  const _PlanningBreakdown({required this.summary});

  final InsightsSummary summary;

  @override
  Widget build(BuildContext context) {
    final total =
        summary.plannedCompletedTasks + summary.unplannedCompletedTasks;
    if (total == 0) {
      return const _SectionEmptyText(
        'Schedule tasks to compare planned vs unscheduled wins.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrimaryLine('${summary.plannedCompletionPercent}% planned'),
        const SizedBox(height: 6),
        _SecondaryLine(
          '${summary.plannedCompletedTasks} planned · ${summary.unplannedCompletedTasks} unscheduled',
        ),
      ],
    );
  }
}

class _PrimaryLine extends StatelessWidget {
  const _PrimaryLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: colors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _SecondaryLine extends StatelessWidget {
  const _SecondaryLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    );
  }
}

class _SectionEmptyText extends StatelessWidget {
  const _SectionEmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.34,
      ),
    );
  }
}

String _taskCountLabel(int count) =>
    count == 1 ? 'task completed' : 'tasks completed';
String _dayCountLabel(int count) => count == 1 ? 'day' : 'days';
