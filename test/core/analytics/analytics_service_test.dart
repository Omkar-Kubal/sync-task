import 'package:flutter_test/flutter_test.dart';
import 'package:synctask/core/analytics/analytics_service.dart';

void main() {
  test('analytics service logs only safe SyncTask events and parameters', () {
    final sink = RecordingAnalyticsSink();
    final service = AnalyticsService(sink);

    service.logEvent(
      'focus_completed',
      parameters: {'duration_minutes': 45, 'was_extended': false},
    );

    expect(sink.events.single.name, 'focus_completed');
    expect(sink.events.single.parameters['duration_minutes'], 45);
  });

  test(
    'analytics service rejects user-content event names keys and values',
    () {
      final service = AnalyticsService(RecordingAnalyticsSink());

      expect(() => service.logEvent('search_query'), throwsArgumentError);
      expect(
        () => service.logEvent(
          'task_created',
          parameters: {'task_title': 'Write report'},
        ),
        throwsArgumentError,
      );
      expect(
        () => service.logEvent(
          'task_created',
          parameters: {'label': 'Write report'},
        ),
        throwsArgumentError,
      );
    },
  );
}
