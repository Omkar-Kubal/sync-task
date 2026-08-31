import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/providers/task_controller.dart';
import '../data/insights_repository.dart';
import '../domain/insights_summary.dart';

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  return InsightsRepository(ref.watch(appDatabaseProvider));
});

final insightsProvider = FutureProvider<InsightsSummary>((ref) {
  return ref.watch(insightsRepositoryProvider).summary();
});
