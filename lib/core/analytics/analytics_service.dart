class AnalyticsEvent {
  const AnalyticsEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object?> parameters;
}

abstract interface class AnalyticsSink {
  void log(AnalyticsEvent event);
}

class RecordingAnalyticsSink implements AnalyticsSink {
  final events = <AnalyticsEvent>[];

  @override
  void log(AnalyticsEvent event) {
    events.add(event);
  }
}

class AnalyticsService {
  const AnalyticsService(this._sink);

  static const _allowedEvents = {
    'task_created',
    'task_completed',
    'folder_created',
    'focus_started',
    'focus_completed',
    'focus_extended',
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

  void logEvent(String name, {Map<String, Object?> parameters = const {}}) {
    if (!_allowedEvents.contains(name)) {
      throw ArgumentError('Unsupported analytics event: $name');
    }
    for (final entry in parameters.entries) {
      if (_blockedFragments.any(entry.key.toLowerCase().contains)) {
        throw ArgumentError('Unsafe analytics parameter: ${entry.key}');
      }
      final value = entry.value;
      if (value is String) {
        throw ArgumentError('String analytics parameter values may contain user content.');
      }
    }

    _sink.log(AnalyticsEvent(name, Map.unmodifiable(parameters)));
  }
}
