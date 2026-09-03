import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._preferences);

  SettingsRepository.memory() : _preferences = null;

  final SharedPreferences? _preferences;
  AppSettings _memorySettings = const AppSettings();

  static const _themeModeKey = 'settings.themeMode';
  static const _notificationsEnabledKey = 'settings.notificationsEnabled';
  static const _focusSoundKey = 'settings.focusSound';
  static const _focusVibrationKey = 'settings.focusVibration';

  Future<AppSettings> load() async {
    final preferences = _preferences;
    if (preferences == null) {
      return _memorySettings;
    }
    return AppSettings(
      themeMode: ThemeMode.values.byName(
        preferences.getString(_themeModeKey) ?? ThemeMode.system.name,
      ),
      notificationsEnabled:
          preferences.getBool(_notificationsEnabledKey) ?? true,
      focusSound: preferences.getBool(_focusSoundKey) ?? true,
      focusVibration: preferences.getBool(_focusVibrationKey) ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    final preferences = _preferences;
    if (preferences == null) {
      _memorySettings = settings;
      return;
    }
    await preferences.setString(_themeModeKey, settings.themeMode.name);
    await preferences.setBool(
      _notificationsEnabledKey,
      settings.notificationsEnabled,
    );
    await preferences.setBool(_focusSoundKey, settings.focusSound);
    await preferences.setBool(_focusVibrationKey, settings.focusVibration);
  }
}
