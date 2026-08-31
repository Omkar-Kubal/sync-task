class NotificationPermissionException implements Exception {}

String productErrorMessage(Object error) {
  if (error is NotificationPermissionException) {
    return 'Task saved. Reminder could not be scheduled.';
  }
  return "Couldn't save task";
}
