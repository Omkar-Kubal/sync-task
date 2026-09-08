import 'dart:async';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../firebase_options.dart';

typedef FirebaseInitializer = Future<void> Function();
typedef CrashlyticsCollectionSetter = Future<void> Function(bool enabled);

class CrashReporter {
  const CrashReporter._();

  static const _maxLogLength = 1024;
  static bool _isInitialized = false;

  static bool get isEnabled => _isInitialized;

  static Future<void> initialize({
    FirebaseInitializer? initializeFirebase,
    CrashlyticsCollectionSetter? setCrashlyticsCollectionEnabled,
  }) async {
    if (_isInitialized) return;

    WidgetsFlutterBinding.ensureInitialized();
    await (initializeFirebase ?? _initializeFirebase)();
    await (setCrashlyticsCollectionEnabled ??
        FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled)(true);
    _isInitialized = true;
  }

  static Future<void> _initializeFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  static Future<void> runAppGuarded(
    FutureOr<void> Function() appRunner, {
    Future<void> Function()? initializeCrashReporter,
  }) async {
    final guarded = runZonedGuarded<Future<void>>(
      () async {
        _installGlobalHandlers();
        unawaited(
          _initializeInBackground(initializeCrashReporter ?? initialize),
        );
        await appRunner();
      },
      (error, stackTrace) {
        unawaited(_recordFatalError(error, stackTrace));
      },
    );
    if (guarded != null) {
      await guarded;
    }
  }

  static Future<void> _initializeInBackground(
    Future<void> Function() initializeCrashReporter,
  ) async {
    try {
      await initializeCrashReporter();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('CrashReporter initialization failed: $error');
      }
      await _recordFatalError(error, stackTrace);
    }
  }

  static void _installGlobalHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(_recordFatalFlutterError(details));
    };

    ui.PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(_recordFatalError(error, stackTrace));
      return true;
    };
  }

  static Future<void> _recordFatalFlutterError(
    FlutterErrorDetails details,
  ) async {
    if (!isEnabled) return;

    if (_isNonFatalFlutterDiagnostic(details)) {
      await FirebaseCrashlytics.instance.recordFlutterError(details);
      return;
    }

    await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }

  static Future<void> _recordFatalError(
    Object error,
    StackTrace stackTrace,
  ) async {
    if (kDebugMode) {
      debugPrint('CrashReporter fatal: $error');
    }

    if (!isEnabled) return;

    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: true,
    );
  }

  static Future<void> recordError(
    Object error, [
    StackTrace? stackTrace,
    String? hint,
  ]) async {
    if (kDebugMode) {
      debugPrint('CrashReporter: $error');
      if (hint != null) debugPrint('CrashReporter hint: $hint');
    }

    if (!isEnabled) return;

    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: hint,
      fatal: false,
    );
  }

  static Future<void> addBreadcrumb(
    String message, {
    String category = 'app',
    Map<String, Object?> data = const {},
  }) async {
    final formatted = _formatBreadcrumb(message, category, data);

    if (kDebugMode) {
      debugPrint('CrashReporter breadcrumb: $formatted');
    }

    if (!isEnabled) return;

    await FirebaseCrashlytics.instance.log(formatted);
  }

  static void unawaitedCapture<T>(Future<T> future, {String? hint}) {
    unawaited(() async {
      try {
        await future;
      } catch (error, stackTrace) {
        await recordError(error, stackTrace, hint);
      }
    }());
  }

  @visibleForTesting
  static String formatBreadcrumbForTesting(
    String message, {
    String category = 'app',
    Map<String, Object?> data = const {},
  }) {
    return _formatBreadcrumb(message, category, data);
  }

  static String _formatBreadcrumb(
    String message,
    String category,
    Map<String, Object?> data,
  ) {
    final safeKeys =
        data.keys
            .where((key) => !_isSensitiveKey(key))
            .map(_sanitizeToken)
            .where((key) => key.isNotEmpty)
            .toList()
          ..sort();

    final buffer = StringBuffer()
      ..write(_sanitizeToken(category))
      ..write(' ')
      ..write(_sanitizeToken(message));

    if (safeKeys.isNotEmpty) {
      buffer
        ..write(' keys=')
        ..write(safeKeys.join(','));
    }

    final formatted = buffer.toString();
    if (formatted.length <= _maxLogLength) return formatted;
    return formatted.substring(0, _maxLogLength);
  }

  @visibleForTesting
  static bool isNonFatalFlutterDiagnosticForTesting(
    FlutterErrorDetails details,
  ) {
    return _isNonFatalFlutterDiagnostic(details);
  }

  static bool _isNonFatalFlutterDiagnostic(FlutterErrorDetails details) {
    final exception = details.exceptionAsString();
    return exception.contains('A RenderFlex overflowed') ||
        exception.contains('ListTile background color or ink splashes');
  }

  static bool _isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('title') ||
        lowerKey.contains('folder_name') ||
        lowerKey.contains('foldername') ||
        lowerKey.contains('reminder_text') ||
        lowerKey.contains('search') ||
        lowerKey.contains('query') ||
        lowerKey.contains('label') ||
        lowerKey.contains('content') ||
        lowerKey.contains('note') ||
        lowerKey.contains('token');
  }

  static String _sanitizeToken(String value) {
    return value
        .replaceAll(RegExp(r'[^A-Za-z0-9_.:-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  @visibleForTesting
  static void resetForTesting() {
    _isInitialized = false;
  }
}


