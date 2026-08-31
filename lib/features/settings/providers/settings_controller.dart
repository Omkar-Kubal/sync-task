import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden during bootstrap.');
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

final settingsControllerProvider = Provider<SettingsController>((ref) {
  return SettingsController(ref.watch(settingsRepositoryProvider));
});

class SettingsController {
  const SettingsController(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> load() {
    return _repository.load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(themeMode: mode));
  }

  Future<void> setFocusSound(bool enabled) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(focusSound: enabled));
  }

  Future<void> setFocusVibration(bool enabled) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(focusVibration: enabled));
  }
}
