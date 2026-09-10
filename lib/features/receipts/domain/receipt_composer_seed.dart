enum ReceiptEntrySource { today, completedSelection, insightsPeriod, history }

class ReceiptComposerSeed {
  const ReceiptComposerSeed({
    required this.source,
    required this.defaultTitle,
    this.selectedTaskIds = const <int>[],
    this.periodStart,
    this.periodEndExclusive,
  });

  const ReceiptComposerSeed.empty()
    : source = ReceiptEntrySource.history,
      defaultTitle = 'Completed tasks',
      selectedTaskIds = const <int>[],
      periodStart = null,
      periodEndExclusive = null;

  final ReceiptEntrySource source;
  final String defaultTitle;
  final List<int> selectedTaskIds;
  final DateTime? periodStart;
  final DateTime? periodEndExclusive;
}
