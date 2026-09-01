import 'package:flutter/material.dart';

import '../../../shared/widgets/sync_grouped_section.dart';
import '../../../shared/widgets/sync_header.dart';
import '../domain/insights_summary.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    this.summary = const InsightsSummary(
      todayFocusRuns: 0,
      weekFocusRuns: 0,
      todayFocusedDuration: Duration.zero,
      weekFocusedDuration: Duration.zero,
      todayCompletedTasks: 0,
      currentStreak: 0,
    ),
    super.key,
  });

  final InsightsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SyncHeader(title: 'Insights'),
            _Section(
              title: 'Today',
              lines: [
                '${summary.todayFocusRuns} Focus runs',
                '${_formatDuration(summary.todayFocusedDuration)} focused',
                '${summary.todayCompletedTasks} tasks completed',
              ],
            ),
            _Section(
              title: 'This Week',
              lines: [
                '${summary.weekFocusRuns} Focus runs',
                '${_formatDuration(summary.weekFocusedDuration)} focused',
              ],
            ),
            _Section(title: 'Streak', lines: ['${summary.currentStreak} days']),
            const _Section(title: 'Activity', lines: ['No Focus activity yet']),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) {
      return '${minutes}m';
    }
    return '${hours}h ${minutes}m';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: SyncGroupedSection(
        dividerIndent: 16,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
