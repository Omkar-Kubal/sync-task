import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../insights/data/insights_repository.dart';
import '../../tasks/providers/task_controller.dart';

final focusStreakProvider = FutureProvider<int>((ref) async {
  final repository = InsightsRepository(ref.watch(appDatabaseProvider));
  final summary = await repository.summary();
  return summary.currentStreak;
});
