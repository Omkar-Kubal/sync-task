import '../domain/active_focus.dart';

class ActiveTimerRepository {
  ActiveTimerRepository.memory();

  ActiveFocus? _focus;

  Future<void> save(ActiveFocus focus) async {
    _focus = focus;
  }

  Future<ActiveFocus?> load() async {
    return _focus;
  }

  Future<void> clear() async {
    _focus = null;
  }
}
