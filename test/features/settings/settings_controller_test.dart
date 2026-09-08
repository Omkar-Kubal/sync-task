import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/features/settings/data/settings_repository.dart';
import 'package:synctasks/features/settings/providers/settings_controller.dart';

void main() {
  test(
    'settings controller persists theme and notification alert preferences',
    () async {
      final repository = SettingsRepository.memory();
      final controller = SettingsController(repository);

      await controller.setThemeMode(ThemeMode.dark);
      await controller.setNotificationsEnabled(false);
      await controller.setDefaultFolder(42);
      await controller.completeOnboarding();

      final settings = await repository.load();
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.defaultFolderId, 42);
      expect(settings.hasCompletedOnboarding, isTrue);
    },
  );

  test('settings controller can clear the default folder', () async {
    final repository = SettingsRepository.memory();
    final controller = SettingsController(repository);

    await controller.setDefaultFolder(42);
    await controller.setDefaultFolder(null);

    final settings = await repository.load();
    expect(settings.defaultFolderId, isNull);
  });
}


