import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.focusSound = true,
    this.focusVibration = true,
    this.defaultFolderId,
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool focusSound;
  final bool focusVibration;
  final int? defaultFolderId;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? focusSound,
    bool? focusVibration,
    int? defaultFolderId,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      focusSound: focusSound ?? this.focusSound,
      focusVibration: focusVibration ?? this.focusVibration,
      defaultFolderId: defaultFolderId ?? this.defaultFolderId,
    );
  }
}
