import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.notificationSound = true,
    this.notificationVibration = true,
    this.soundEffects = true,
    this.mildHaptics = true,
    this.defaultFolderId,
    this.hasCompletedOnboarding = false,
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool notificationSound;
  final bool notificationVibration;
  final bool soundEffects;
  final bool mildHaptics;
  final int? defaultFolderId;
  final bool hasCompletedOnboarding;

  static const Object _unset = Object();

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? notificationSound,
    bool? notificationVibration,
    bool? soundEffects,
    bool? mildHaptics,
    Object? defaultFolderId = _unset,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationVibration:
          notificationVibration ?? this.notificationVibration,
      soundEffects: soundEffects ?? this.soundEffects,
      mildHaptics: mildHaptics ?? this.mildHaptics,
      defaultFolderId: identical(defaultFolderId, _unset)
          ? this.defaultFolderId
          : defaultFolderId as int?,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
