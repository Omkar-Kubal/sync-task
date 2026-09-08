import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/crash/crash_reporter.dart';

void main() {
  group('CrashReporter', () {
    setUp(CrashReporter.resetForTesting);

    test('initializes Firebase and Crashlytics collection once', () async {
      var firebaseInitializations = 0;
      final collectionValues = <bool>[];

      await CrashReporter.initialize(
        initializeFirebase: () async {
          firebaseInitializations += 1;
        },
        setCrashlyticsCollectionEnabled: (enabled) async {
          collectionValues.add(enabled);
        },
      );
      await CrashReporter.initialize(
        initializeFirebase: () async {
          firebaseInitializations += 1;
        },
        setCrashlyticsCollectionEnabled: (enabled) async {
          collectionValues.add(enabled);
        },
      );

      expect(CrashReporter.isEnabled, isTrue);
      expect(firebaseInitializations, 1);
      expect(collectionValues, [true]);
    });

    test('runs the app before crash reporter initialization completes', () async {
      final initializeCompleter = Completer<void>();
      var appRan = false;

      await CrashReporter.runAppGuarded(
        () {
          appRan = true;
        },
        initializeCrashReporter: () => initializeCompleter.future,
      );

      expect(appRan, isTrue);
      initializeCompleter.complete();
    });

    test('breadcrumb formatting keeps keys and strips values', () {
      final formatted = CrashReporter.formatBreadcrumbForTesting(
        'saved',
        category: 'task',
        data: {
          'flow': 'quick_add',
          'title': 'Private task title',
          'folderName': 'Work',
          'reminder_text': 'Call person',
          'search': 'secret query',
          'scheduled_days_ahead': 2,
        },
      );

      expect(formatted, contains('task saved'));
      expect(formatted, contains('flow'));
      expect(formatted, contains('scheduled_days_ahead'));
      expect(formatted, isNot(contains('quick_add')));
      expect(formatted, isNot(contains('Private')));
      expect(formatted, isNot(contains('Work')));
      expect(formatted, isNot(contains('Call')));
      expect(formatted, isNot(contains('secret')));
    });

    test('Flutter UI diagnostics are classified as non-fatal', () {
      final details = FlutterErrorDetails(
        exception: FlutterError('A RenderFlex overflowed by 12 pixels'),
      );

      expect(
        CrashReporter.isNonFatalFlutterDiagnosticForTesting(details),
        isTrue,
      );
    });

    test('ordinary Flutter errors stay fatal', () {
      final details = FlutterErrorDetails(
        exception: FlutterError('Null check operator used on a null value'),
      );

      expect(
        CrashReporter.isNonFatalFlutterDiagnosticForTesting(details),
        isFalse,
      );
    });
  });
}


