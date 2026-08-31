import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_task/features/settings/data/settings_repository.dart';
import 'package:sync_task/features/settings/providers/settings_controller.dart';

void main() {
  test('settings controller persists theme focus sound and vibration preferences', () async {
    final repository = SettingsRepository.memory();
    final controller = SettingsController(repository);

    await controller.setThemeMode(ThemeMode.dark);
    await controller.setFocusSound(false);
    await controller.setFocusVibration(false);

    final settings = await repository.load();
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.focusSound, isFalse);
    expect(settings.focusVibration, isFalse);
  });
}
