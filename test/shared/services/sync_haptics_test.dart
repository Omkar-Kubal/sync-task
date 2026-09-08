import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/shared/services/sync_haptics.dart';

void main() {
  setUp(() {
    SyncHaptics.resetForTesting();
  });
  tearDown(() {
    SyncHaptics.resetForTesting();
  });

  testWidgets('all app haptics use the softest selection feedback', (
    tester,
  ) async {
    final haptics = _captureHaptics(tester);

    for (final feedback in [
      SyncHaptics.selection,
      SyncHaptics.action,
      SyncHaptics.complete,
      SyncHaptics.destructive,
    ]) {
      feedback();
      SyncHaptics.resetForTesting();
    }

    await tester.pump();

    expect(haptics, hasLength(4));
    expect(haptics, everyElement(equals('HapticFeedbackType.selectionClick')));
  });

  testWidgets('rapid repeated haptics are throttled', (tester) async {
    final haptics = _captureHaptics(tester);

    SyncHaptics.action();
    SyncHaptics.action();
    SyncHaptics.action();

    await tester.pump();

    expect(haptics, hasLength(1));
  });
}

List<Object?> _captureHaptics(WidgetTester tester) {
  final calls = <Object?>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add(call.arguments);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}


