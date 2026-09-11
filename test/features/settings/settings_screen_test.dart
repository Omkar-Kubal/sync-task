import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:synctasks/core/theme/app_theme.dart';
import 'package:synctasks/features/settings/data/settings_repository.dart';
import 'package:synctasks/features/settings/providers/settings_controller.dart';
import 'package:synctasks/features/settings/screens/settings_screen.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';
import 'package:synctasks/shared/widgets/sync_grouped_section.dart';

void main() {
  testWidgets(
    'settings screen shows required General Support and About groups',
    (tester) async {
      await tester.pumpWidget(
        _settingsApp(repository: SettingsRepository.memory()),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.byType(SyncGroupedSection), findsNWidgets(4));

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Default Folder'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('SyncTasks Pro'), findsOneWidget);
      expect(find.text("What's New"), findsOneWidget);
      expect(find.text('Help & Feedback'), findsOneWidget);
      expect(find.text('SyncTasks'), findsOneWidget);
      expect(find.text('Fast, local-first task planning'), findsOneWidget);
      expect(find.textContaining('focus', findRichText: true), findsNothing);
      expect(find.text('Version 1.0.0+1'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Local Storage'), findsNothing);
    },
  );

  testWidgets('settings top nav follows app chrome sizing', (tester) async {
    await tester.pumpWidget(
      _settingsApp(repository: SettingsRepository.memory()),
    );

    final title = tester.widget<Text>(find.text('Settings'));
    final titleTopLeft = tester.getTopLeft(find.text('Settings'));
    final closeTopLeft = tester.getTopLeft(
      find.bySemanticsLabel('Close settings'),
    );
    final closeSize = tester.getSize(find.bySemanticsLabel('Close settings'));

    expect(title.style?.fontSize, 29);
    expect(titleTopLeft.dx, lessThan(closeTopLeft.dx));
    expect(closeSize, const Size(46, 46));
  });

  testWidgets('settings rows use compact list typography and icon sizing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _settingsApp(repository: SettingsRepository.memory()),
    );

    final themeText = tester.widget<Text>(find.text('Theme'));
    final valueText = tester.widget<Text>(find.text('System'));

    expect(themeText.style?.fontSize, 15);
    expect(themeText.style?.fontWeight, FontWeight.w500);
    expect(valueText.style?.fontSize, 13);
    expect(
      tester.getSize(find.byKey(const Key('settings-theme-icon-tile'))),
      const Size(40, 40),
    );
  });

  testWidgets('settings app identity uses compact circular logo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _settingsApp(repository: SettingsRepository.memory()),
    );

    final logo = tester.widget<Container>(
      find.byKey(const Key('settings-app-logo-circle')),
    );
    final decoration = logo.decoration! as BoxDecoration;
    final appName = tester.widget<Text>(find.text('SyncTasks'));

    expect(
      tester.getSize(find.byKey(const Key('settings-app-logo-circle'))),
      const Size(44, 44),
    );
    expect(decoration.shape, BoxShape.circle);
    expect(
      find.descendant(
        of: find.byKey(const Key('settings-app-logo-circle')),
        matching: find.byType(ClipOval),
      ),
      findsOneWidget,
    );
    expect(appName.style?.fontSize, 16);
  });

  testWidgets('settings screen removes non-v1 and unsupported rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _settingsApp(repository: SettingsRepository.memory()),
    );

    expect(find.text('Security'), findsNothing);
    expect(find.text('Sound'), findsNothing);
    expect(find.text('Vibration'), findsNothing);
    expect(find.text('Mild Haptics'), findsNothing);
    expect(find.text('Notion - Coming Soon'), findsNothing);
    expect(find.text('About local storage'), findsNothing);
    expect(find.text('Feedback'), findsNothing);
    expect(find.text('Version'), findsNothing);
  });

  testWidgets('settings rows use requested Hugeicons', (tester) async {
    await tester.pumpWidget(
      _settingsApp(
        repository: SettingsRepository.memory(),
        brightness: Brightness.light,
      ),
    );

    final expectedIcons = {
      'Default Folder': HugeIcons.strokeRoundedFolder02,
      'Sound Effects': HugeIcons.strokeRoundedVolumeUp,
      'Notifications': HugeIcons.strokeRoundedBellDot,
      "What's New": HugeIcons.strokeRoundedBadgeAlert,
      'Help & Feedback': HugeIcons.strokeRoundedCommentAdd01,
      'Privacy Policy': HugeIcons.strokeRoundedBiometricAccess,
    };

    for (final entry in expectedIcons.entries) {
      final icon = tester.widget<HugeIcon>(
        find.descendant(
          of: find.widgetWithText(ListTile, entry.key),
          matching: find.byType(HugeIcon),
        ),
      );

      expect(icon.icon, entry.value, reason: entry.key);
      expect(icon.size, 20, reason: entry.key);
      expect(icon.strokeWidth, 1.5, reason: entry.key);
    }
  });

  testWidgets('theme row opens picker and persists selected mode', (
    tester,
  ) async {
    final repository = SettingsRepository.memory();

    await tester.pumpWidget(_settingsApp(repository: repository));

    await tester.tap(find.widgetWithText(ListTile, 'Theme'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Theme'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(find.text('Dark'), findsOneWidget);
    expect((await repository.load()).themeMode, ThemeMode.dark);
  });

  testWidgets('notifications row combines sound and vibration preferences', (
    tester,
  ) async {
    final repository = SettingsRepository.memory();

    await tester.pumpWidget(_settingsApp(repository: repository));

    await tester.tap(find.widgetWithText(ListTile, 'Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Notification Alerts'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Vibration'), findsOneWidget);
    expect(find.text('Focus Alerts'), findsNothing);
    expect(find.textContaining('focus', findRichText: true), findsNothing);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Sound'));
    await tester.pumpAndSettle();

    expect((await repository.load()).notificationSound, isFalse);
    expect((await repository.load()).soundEffects, isTrue);
  });

  testWidgets('sound effects row persists app sound preference separately', (
    tester,
  ) async {
    final repository = SettingsRepository.memory();

    await tester.pumpWidget(_settingsApp(repository: repository));

    expect(find.widgetWithText(ListTile, 'Sound Effects'), findsOneWidget);
    expect(find.text('On'), findsWidgets);

    await tester.tap(find.widgetWithText(ListTile, 'Sound Effects'));
    await tester.pumpAndSettle();

    expect(find.text('Sound Effects'), findsWidgets);
    expect(find.text('Preview'), findsOneWidget);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Sound Effects'));
    await tester.pumpAndSettle();

    final settings = await repository.load();
    expect(settings.soundEffects, isFalse);
    expect(settings.notificationSound, isTrue);
  });

  testWidgets('default folder row persists the selected quick-add folder', (
    tester,
  ) async {
    final repository = SettingsRepository.memory();
    final database = AppDatabase.memory();
    addTearDown(database.close);
    final work = await FolderRepository(database).createFolder('Work');

    await tester.pumpWidget(
      _settingsApp(repository: repository, database: database),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Default Folder'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Default Folder'), findsOneWidget);
    expect(find.text('Inbox'), findsWidgets);
    expect(find.text('Work'), findsOneWidget);

    await tester.tap(find.text('Work').last);
    await tester.pumpAndSettle();

    expect((await repository.load()).defaultFolderId, work.id);
    expect(find.widgetWithText(ListTile, 'Default Folder'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Default Folder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inbox').last);
    await tester.pumpAndSettle();

    expect((await repository.load()).defaultFolderId, isNull);
  });

  testWidgets('whats new opens the changelog bottom sheet', (tester) async {
    await tester.pumpWidget(
      _settingsApp(repository: SettingsRepository.memory()),
    );

    await tester.scrollUntilVisible(find.text("What's New"), 160);
    await tester.tap(find.widgetWithText(ListTile, "What's New"));
    await tester.pumpAndSettle();

    expect(find.text("What's New"), findsWidgets);
    expect(find.text('v1.0.0'), findsOneWidget);
    expect(find.text('September 8, 2026'), findsOneWidget);
    expect(find.text('SyncTasks launch'), findsOneWidget);
    expect(find.text('Quick Add Polish'), findsOneWidget);
    expect(find.text('Upcoming Views'), findsOneWidget);
    expect(find.text('Local Reminders'), findsOneWidget);
    expect(find.text('Monthly Analytics'), findsNothing);
    expect(find.text('Receipt OCR Removed'), findsNothing);
    expect(find.byKey(const Key('whats-new-bottom-sheet')), findsOneWidget);
  });

  testWidgets('help feedback opens support actions bottom sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      _settingsApp(repository: SettingsRepository.memory()),
    );

    await tester.scrollUntilVisible(find.text('Help & Feedback'), 160);
    await tester.tap(find.widgetWithText(ListTile, 'Help & Feedback'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('help-feedback-bottom-sheet')), findsOneWidget);
    expect(find.text('Help & Feedback'), findsWidgets);
    expect(find.text('Support'), findsWidgets);
    expect(find.text('Feature Requests'), findsOneWidget);
    expect(find.text('Support Email'), findsOneWidget);
    expect(syncTasksSupportEmailUrl, 'mailto:support@appylab.org');
    expect(
      syncTasksFeatureRequestsUrl,
      'mailto:support@appylab.org?subject=Feature%20Request',
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('help-feedback-bottom-sheet')),
        matching: find.byIcon(Icons.open_in_new_rounded),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('about section omits local storage details', (tester) async {
    await tester.pumpWidget(
      _settingsApp(repository: SettingsRepository.memory()),
    );

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Local Storage'), findsNothing);
    expect(find.text('On-device Storage'), findsNothing);
  });

  testWidgets('privacy policy row opens the published policy URL', (
    tester,
  ) async {
    final launched = <Uri>[];
    await tester.pumpWidget(
      _settingsApp(
        repository: SettingsRepository.memory(),
        privacyPolicyLauncher: (uri) async {
          launched.add(uri);
          return true;
        },
      ),
    );

    await tester.scrollUntilVisible(find.text('Privacy Policy'), 160);
    await tester.tap(find.widgetWithText(ListTile, 'Privacy Policy'));
    await tester.pumpAndSettle();

    expect(launched, [
      Uri.parse('https://sites.google.com/view/my-todos/privacy-policy'),
    ]);
  });
}

Widget _settingsApp({
  required SettingsRepository repository,
  Brightness brightness = Brightness.dark,
  AppDatabase? database,
  Future<bool> Function(Uri uri)? privacyPolicyLauncher,
}) {
  final db = database ?? AppDatabase.memory();
  if (database == null) {
    addTearDown(db.close);
  }
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(repository),
      appDatabaseProvider.overrideWithValue(db),
      if (privacyPolicyLauncher != null)
        privacyPolicyUrlLauncherProvider.overrideWithValue(
          privacyPolicyLauncher,
        ),
    ],
    child: MaterialApp(
      theme: buildSyncTasksTheme(brightness),
      home: const SettingsScreen(),
    ),
  );
}
