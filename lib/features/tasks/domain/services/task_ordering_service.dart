class TaskOrderingService {
  const TaskOrderingService._();

  static List<int> mergeVisibleOrder({
    required List<int> globalIds,
    required List<int> originalVisibleIds,
    required List<int> reorderedVisibleIds,
  }) {
    final originalSet = originalVisibleIds.toSet();
    final reorderedSet = reorderedVisibleIds.toSet();
    if (originalSet.length != reorderedSet.length ||
        !originalSet.containsAll(reorderedSet) ||
        !reorderedSet.containsAll(originalSet)) {
      throw ArgumentError('Reordered visible ids must contain the same task ids.');
    }

    final firstVisibleIndex = globalIds.indexWhere(originalSet.contains);
    if (firstVisibleIndex == -1) {
      return globalIds;
    }

    final withoutVisible = [
      for (final id in globalIds)
        if (!originalSet.contains(id)) id,
    ];
    return [
      ...withoutVisible.take(firstVisibleIndex),
      ...reorderedVisibleIds,
      ...withoutVisible.skip(firstVisibleIndex),
    ];
  }
}
