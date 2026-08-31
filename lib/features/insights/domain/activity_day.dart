class ActivityDay {
  const ActivityDay({
    required this.date,
    required this.completedFocusRunCount,
    required this.intensity,
  });

  final DateTime date;
  final int completedFocusRunCount;
  final int intensity;
}
