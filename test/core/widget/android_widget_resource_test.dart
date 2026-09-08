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
      }
    },
  );

  test('medium Android widget uses fixed rows and an overflow summary', () {
    final xml = File(
      'android/app/src/main/res/layout/widget_medium.xml',
    ).readAsStringSync();

    expect(xml, contains('@+id/widget_more_row'));
    expect(xml, contains('@+id/widget_more_text'));
    expect(xml, isNot(contains('@+id/widget_task3_row')));

    for (final rowId in ['widget_task1_row', 'widget_task2_row']) {
      final rowPattern = RegExp(
        '<LinearLayout[^>]*android:id="@\\+id/$rowId"[\\s\\S]*?>',
        multiLine: true,
      );
      final match = rowPattern.firstMatch(xml);
      expect(match, isNotNull, reason: '$rowId should exist');
      expect(match!.group(0), contains('android:layout_height="28dp"'));
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

  test(
    'Android widgets use the native SyncTasks logo asset, not the checkmark',
    () {
      final layoutDir = Directory('android/app/src/main/res/layout');
      final widgetLayouts = layoutDir
          .listSync()
          .whereType<File>()
          .where((file) => file.uri.pathSegments.last.startsWith('widget_'))
          .where((file) => file.path.endsWith('.xml'));

      for (final layout in widgetLayouts) {
        final xml = layout.readAsStringSync();
        expect(xml, isNot(contains('@drawable/ic_synctasks_logo')));
        expect(xml, contains('@drawable/synctasks_widget_logo'));
      }

      expect(
        File(
          'android/app/src/main/res/drawable-nodpi/synctasks_widget_logo.png',
        ).existsSync(),
        isTrue,
      );
    },
  );

  test('Android manifest exposes URL launcher schemes used by settings', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android.intent.action.VIEW'));
    expect(manifest, contains('android:scheme="https"'));
    expect(manifest, contains('android:scheme="mailto"'));
  });
}


