import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return const AnalyticsService(FirebaseAnalyticsSink());
});

class AnalyticsEvent {
  const AnalyticsEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object?> parameters;
}

abstract interface class AnalyticsSink {
  Future<void> log(AnalyticsEvent event);
}

class RecordingAnalyticsSink implements AnalyticsSink {
  final events = <AnalyticsEvent>[];

  @override
  Future<void> log(AnalyticsEvent event) async {
    events.add(event);
  }
}

typedef FirebaseAnalyticsEventLogger =
    Future<void> Function(String name, Map<String, Object> parameters);

class FirebaseAnalyticsSink implements AnalyticsSink {
  const FirebaseAnalyticsSink({FirebaseAnalyticsEventLogger? logEvent})
    : _logEvent = logEvent ?? _logFirebaseEvent;

  final FirebaseAnalyticsEventLogger _logEvent;

  @override
  Future<void> log(AnalyticsEvent event) async {
    await _logEvent(event.name, _firebaseParameters(event.parameters));
  }

  static Map<String, Object> _firebaseParameters(
    Map<String, Object?> parameters,
  ) {
    return {
      for (final entry in parameters.entries)
        if (_firebaseParameterValue(entry.value) case final value?)
          entry.key: value,
    };
  }

  static Object? _firebaseParameterValue(Object? value) {
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is num) {
      return value;
    }
    return null;
  }
}

Future<void> _logFirebaseEvent(
  String name,
  Map<String, Object> parameters,
) async {
  if (Firebase.apps.isEmpty) return;

  if (kDebugMode) {
    debugPrint('Analytics event: $name keys=${parameters.keys.join(',')}');
  }

  await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
}

class AnalyticsService {
  const AnalyticsService(this._sink);

  static const _allowedEvents = {
    'task_created',
    'task_completed',
    'folder_created',
    'insights_opened',
  };

  static const _blockedFragments = {
    'title',
    'folder_name',
    'reminder_text',
    'search',
    'query',
    'label',
    'content',
  };

  final AnalyticsSink _sink;

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    if (!_allowedEvents.contains(name)) {
      throw ArgumentError('Unsupported analytics event: $name');
    }
    for (final entry in parameters.entries) {
      if (_blockedFragments.any(entry.key.toLowerCase().contains)) {
        throw ArgumentError('Unsafe analytics parameter: ${entry.key}');
      }
      final value = entry.value;
      if (value is String) {
        throw ArgumentError(
          'String analytics parameter values may contain user content.',
        );
      }
    }

    try {
      await _sink.log(AnalyticsEvent(name, Map.unmodifiable(parameters)));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Analytics event failed: $name ($error)');
      }
    }
  }
}

typedef ScreenViewLogger = Future<void> Function(String screenName);

class AppAnalytics {
  const AppAnalytics._();

  static Future<void> logScreenView(String screenName) async {
    if (Firebase.apps.isEmpty) return;

    if (kDebugMode) {
      debugPrint('Analytics screen_view: $screenName');
    }

    await FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  static String? screenNameForUri(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    return switch (segments) {
      ['splash'] => 'splash',
      ['onboarding'] => 'onboarding',
      ['today'] => 'today',
      ['today', 'search'] => 'search',
      ['upcoming'] => 'upcoming',
      ['lists'] => 'lists',
      ['lists', 'all'] => 'lists_all',
      ['lists', 'completed'] => 'lists_completed',
      ['lists', 'inbox'] => 'lists_inbox',
      ['lists', 'folder', _] => 'folder_detail',
      ['lists', 'reminders'] => 'reminders',
      ['lists', 'insights'] => 'insights',
      ['settings'] => 'settings',
      ['quick-add'] => 'quick_add',
      _ => null,
    };
  }
}

class AppAnalyticsRouteTracker {
  factory AppAnalyticsRouteTracker({
    ScreenViewLogger logScreenView = AppAnalytics.logScreenView,
  }) {
    return AppAnalyticsRouteTracker._(logScreenView);
  }

  AppAnalyticsRouteTracker._(this._logScreenView);

  final ScreenViewLogger _logScreenView;
  String? _lastScreenName;

  Future<void> track(Uri uri) async {
    final screenName = AppAnalytics.screenNameForUri(uri);
    if (screenName == null || screenName == _lastScreenName) return;

    _lastScreenName = screenName;
    await _logScreenView(screenName);
  }
}
