import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/features/tasks/domain/services/task_ordering_service.dart';

void main() {
  test('reorders visible tasks back into global order at the first visible slot', () {
    final result = TaskOrderingService.mergeVisibleOrder(
      globalIds: [1, 2, 3, 4],
      originalVisibleIds: [1, 3],
      reorderedVisibleIds: [3, 1],
    );

    expect(result, [3, 1, 2, 4]);
  });

  test('rejects reordered visible ids that are not the same set', () {
    expect(
      () => TaskOrderingService.mergeVisibleOrder(
        globalIds: [1, 2, 3],
        originalVisibleIds: [1, 3],
        reorderedVisibleIds: [3, 2],
      ),
      throwsArgumentError,
    );
  });
}
