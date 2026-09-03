import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity_day.dart';
import 'insights_provider.dart';

final activityGridProvider = FutureProvider.family<List<ActivityDay>, int>((
  ref,
  year,
) {
  return ref.watch(insightsRepositoryProvider).yearActivity(year);
});
