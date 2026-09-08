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
  static const _notificationSoundKey = 'settings.notificationSound';
  static const _notificationVibrationKey = 'settings.notificationVibration';
  static const _mildHapticsKey = 'settings.mildHaptics';
  static const _defaultFolderIdKey = 'settings.defaultFolderId';
  static const _hasCompletedOnboardingKey = 'settings.hasCompletedOnboarding';

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
      notificationSound: preferences.getBool(_notificationSoundKey) ?? true,
      notificationVibration:
          preferences.getBool(_notificationVibrationKey) ?? true,
      mildHaptics: preferences.getBool(_mildHapticsKey) ?? true,
      defaultFolderId: preferences.getInt(_defaultFolderIdKey),
      hasCompletedOnboarding:
          preferences.getBool(_hasCompletedOnboardingKey) ?? false,
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
    await preferences.setBool(
      _notificationSoundKey,
      settings.notificationSound,
    );
    await preferences.setBool(
      _notificationVibrationKey,
      settings.notificationVibration,
    );
    await preferences.setBool(_mildHapticsKey, settings.mildHaptics);
    final defaultFolderId = settings.defaultFolderId;
    if (defaultFolderId == null) {
      await preferences.remove(_defaultFolderIdKey);
    } else {
      await preferences.setInt(_defaultFolderIdKey, defaultFolderId);
    }
    await preferences.setBool(
      _hasCompletedOnboardingKey,
      settings.hasCompletedOnboarding,
    );
  }
}


