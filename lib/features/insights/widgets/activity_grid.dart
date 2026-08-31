import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/synctask_color_scheme.dart';
import '../domain/activity_day.dart';

class ActivityGrid extends StatelessWidget {
  const ActivityGrid({required this.days, super.key});

  final List<ActivityDay> days;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTaskColorScheme.of(context);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final day in days)
          Semantics(
            label:
                '${DateFormat.yMMMMd().format(day.date)}: ${day.completedFocusRunCount} completed focus runs',
            child: Container(
              width: 10,
              height: 10,
              color: colors.activityIntensity[day.intensity],
            ),
          ),
      ],
    );
  }
}
