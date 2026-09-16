import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

final settingsProvider = FutureProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).load();
});

final settingsControllerProvider = Provider<SettingsController>((ref) {
  return SettingsController(
    ref.watch(settingsRepositoryProvider),
    onChanged: () => ref.invalidate(settingsProvider),
  );
});

class SettingsController {
  const SettingsController(this._repository, {this.onChanged});

  final SettingsRepository _repository;
  final VoidCallback? onChanged;

  Future<AppSettings> load() {
    return _repository.load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(themeMode: mode));
    onChanged?.call();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(notificationsEnabled: enabled));
    onChanged?.call();
  }

  Future<void> setNotificationSound(bool enabled) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(notificationSound: enabled));
    onChanged?.call();
  }

  Future<void> setNotificationVibration(bool enabled) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(notificationVibration: enabled));
    onChanged?.call();
  }

  Future<void> setSoundEffects(bool enabled) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(soundEffects: enabled));
    onChanged?.call();
  }

  Future<void> setMildHaptics(bool enabled) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(mildHaptics: enabled));
    onChanged?.call();
  }

  Future<void> setDefaultFolder(int? folderId) async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(defaultFolderId: folderId));
    onChanged?.call();
  }

  Future<void> completeOnboarding() async {
    final settings = await _repository.load();
    await _repository.save(settings.copyWith(hasCompletedOnboarding: true));
    onChanged?.call();
  }
}
