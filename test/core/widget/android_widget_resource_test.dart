import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Android widget layouts avoid raw View tags unsupported by RemoteViews',
    () {
      final layoutDir = Directory('android/app/src/main/res/layout');
      final widgetLayouts = layoutDir
          .listSync()
          .whereType<File>()
          .where((file) => file.uri.pathSegments.last.startsWith('widget_'))
          .where((file) => file.path.endsWith('.xml'));

      expect(widgetLayouts, isNotEmpty);

      for (final layout in widgetLayouts) {
        final xml = layout.readAsStringSync();

        expect(
          RegExp(r'<\s*View(?:\s|/|>)').hasMatch(xml),
          isFalse,
          reason:
              '${layout.path} is an AppWidget RemoteViews layout. '
              'Raw android.view.View is not reliably accepted by launcher '
              'RemoteViews inflation; use a supported widget class such as '
              'TextView for dividers/spacers.',
        );
        expect(xml, contains('android:forceDarkAllowed="false"'));
      }
    },
  );

  test('Android manifest exposes three independently placeable widgets', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('.SyncTasksProgressWidget'));
    expect(manifest, contains('.SyncTasksInboxWidget'));
    expect(manifest, contains('.SyncTasksTodayWidget'));
    expect(
      manifest,
      contains('es.antonborri.home_widget.HomeWidgetBackgroundReceiver'),
    );
    expect(manifest, contains('@xml/widget_progress_info'));
    expect(manifest, contains('@xml/widget_inbox_info'));
    expect(manifest, contains('@xml/widget_today_info'));
  });

  test('Android widget provider metadata points at the three layouts', () {
    final providerLayouts = {
      'android/app/src/main/res/xml/widget_progress_info.xml':
          '@layout/widget_progress',
      'android/app/src/main/res/xml/widget_inbox_info.xml':
          '@layout/widget_inbox',
      'android/app/src/main/res/xml/widget_today_info.xml':
          '@layout/widget_today',
    };

    for (final entry in providerLayouts.entries) {
      final file = File(entry.key);
      expect(file.existsSync(), isTrue, reason: '${entry.key} should exist');
      final xml = file.readAsStringSync();
      expect(xml, contains(entry.value));
      expect(xml, contains('android:widgetCategory="home_screen"'));
    }
  });

  test('Android widgets have light and dark theme color resources', () {
    final lightColors = File(
      'android/app/src/main/res/values/colors.xml',
    ).readAsStringSync();
    final darkColorsFile = File(
      'android/app/src/main/res/values-night/colors.xml',
    );

    expect(darkColorsFile.existsSync(), isTrue);
    final darkColors = darkColorsFile.readAsStringSync();

    for (final colorName in [
      'widget_light_surface',
      'widget_light_text_primary',
      'widget_light_text_secondary',
      'widget_light_divider',
      'widget_light_icon',
      'widget_light_checkbox',
      'widget_light_surface_stroke',
      'widget_light_chip_bg',
      'widget_control_bg',
      'widget_control_text',
    ]) {
      expect(lightColors, contains('name="$colorName"'));
      expect(darkColors, contains('name="$colorName"'));
    }

    expect(
      lightColors,
      contains('<color name="widget_light_surface">#FFFFFF</color>'),
    );
    expect(
      darkColors,
      contains('<color name="widget_light_surface">#151517</color>'),
    );
    expect(
      lightColors,
      contains('<color name="widget_control_bg">#0F0F10</color>'),
    );
    expect(
      darkColors,
      contains('<color name="widget_control_bg">#F7F7FA</color>'),
    );
  });

  test('Android widget drawables use theme-aware color resources', () {
    final background = File(
      'android/app/src/main/res/drawable/widget_light_background.xml',
    ).readAsStringSync();
    final count = File(
      'android/app/src/main/res/drawable/widget_light_count_bg.xml',
    ).readAsStringSync();
    final control = File(
      'android/app/src/main/res/drawable/widget_dark_circle.xml',
    ).readAsStringSync();
    final progress = File(
      'android/app/src/main/res/drawable/ic_widget_progress_dot.xml',
    ).readAsStringSync();

    expect(background, contains('@color/widget_light_surface'));
    expect(background, contains('@color/widget_light_surface_stroke'));
    expect(count, contains('@color/widget_light_chip_bg'));
    expect(control, contains('@color/widget_control_bg'));
    expect(progress, contains('@color/widget_control_bg'));
  });

  test('Today Android widget uses six fixed rows and an overflow summary', () {
    final xml = File(
      'android/app/src/main/res/layout/widget_today.xml',
    ).readAsStringSync();

    expect(xml, contains('@+id/widget_more_row'));
    expect(xml, contains('@+id/widget_more_text'));
    expect(xml, contains('Tap circles to complete'));

    for (var i = 1; i <= 6; i++) {
      final rowId = 'widget_task${i}_row';
      expect(xml, contains('@+id/widget_task${i}_checkbox'));
      final rowPattern = RegExp(
        '<LinearLayout[^>]*android:id="@\\+id/$rowId"[\\s\\S]*?>',
        multiLine: true,
      );
      final match = rowPattern.firstMatch(xml);
      expect(match, isNotNull, reason: '$rowId should exist');
      expect(match!.group(0), contains('android:layout_height="32dp"'));
      expect(match.group(0), isNot(contains('android:layout_weight')));
    }

    final moreRowPattern = RegExp(
      '<LinearLayout[^>]*android:id="@\\+id/widget_more_row"[\\s\\S]*?>',
      multiLine: true,
    );
    final moreRowMatch = moreRowPattern.firstMatch(xml);
    expect(moreRowMatch, isNotNull);
    expect(moreRowMatch!.group(0), contains('android:layout_height="24dp"'));
  });

  test('Android widgets do not use the old checkmark logo asset', () {
    final layoutDir = Directory('android/app/src/main/res/layout');
    final widgetLayouts = layoutDir
        .listSync()
        .whereType<File>()
        .where((file) => file.uri.pathSegments.last.startsWith('widget_'))
        .where((file) => file.path.endsWith('.xml'));

    for (final layout in widgetLayouts) {
      final xml = layout.readAsStringSync();
      expect(xml, isNot(contains('@drawable/ic_synctasks_logo')));
    }

    expect(
      File(
        'android/app/src/main/res/drawable-nodpi/synctasks_widget_logo.png',
      ).existsSync(),
      isTrue,
    );
  });

  test('Android manifest exposes URL launcher schemes used by settings', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.intent.action.VIEW'));
    expect(manifest, contains('android:scheme="https"'));
    expect(manifest, contains('android:scheme="mailto"'));
  });
}
