enum RecurrenceType {
  daily,
  weekly,
  monthly;

  static RecurrenceType fromStorage(String value) {
    return RecurrenceType.values.firstWhere((type) => type.name == value);
  }
}
