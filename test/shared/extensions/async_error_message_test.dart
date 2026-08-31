import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/shared/extensions/async_error_message.dart';

void main() {
  test('maps raw storage and notification failures to product language', () {
    expect(productErrorMessage(Exception('sqlite disk I/O error')), "Couldn't save task");
    expect(productErrorMessage(NotificationPermissionException()), 'Task saved. Reminder could not be scheduled.');
  });
}
