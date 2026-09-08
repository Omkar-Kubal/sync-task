class QuickAddParseResult {
  const QuickAddParseResult({
    required this.title,
    this.scheduledDate,
    this.hasDateInstruction = false,
  });

  final String title;
  final DateTime? scheduledDate;
  final bool hasDateInstruction;

  static const Object _unset = Object();

  QuickAddParseResult copyWith({
    String? title,
    Object? scheduledDate = _unset,
    bool? hasDateInstruction,
  }) {
    return QuickAddParseResult(
      title: title ?? this.title,
      scheduledDate: identical(scheduledDate, _unset)
          ? this.scheduledDate
          : scheduledDate as DateTime?,
      hasDateInstruction: hasDateInstruction ?? this.hasDateInstruction,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuickAddParseResult &&
            runtimeType == other.runtimeType &&
            title == other.title &&
            scheduledDate == other.scheduledDate &&
            hasDateInstruction == other.hasDateInstruction;
  }

  @override
  int get hashCode => Object.hash(title, scheduledDate, hasDateInstruction);

  @override
  String toString() {
    return 'QuickAddParseResult(title: $title, '
        'scheduledDate: $scheduledDate, '
        'hasDateInstruction: $hasDateInstruction)';
  }
}


