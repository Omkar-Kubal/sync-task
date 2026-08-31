import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/active_focus.dart';
import 'focus_controller.dart';

final activeFocusProvider = Provider<ActiveFocus?>((ref) {
  return ref.watch(focusControllerProvider).activeFocus;
});
