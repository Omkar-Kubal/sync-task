import 'package:flutter_test/flutter_test.dart';
import 'package:synctasks/core/analytics/analytics_service.dart';
import 'package:synctasks/core/database/app_database.dart';
import 'package:synctasks/features/tasks/data/folder_repository.dart';
import 'package:synctasks/features/tasks/data/task_repository.dart';
import 'package:synctasks/features/tasks/domain/task.dart';
import 'package:synctasks/features/tasks/providers/task_controller.dart';

void main() {
  test(
    'analytics service logs only safe SyncTasks events and parameters',
    () async {
      final sink = RecordingAnalyticsSink();
      final service = AnalyticsService(sink);

      await service.logEvent(
        'task_completed',
        parameters: {'duration_minutes': 45, 'has_reminder': true},
      );

      expect(sink.events.single.name, 'task_completed');
      expect(sink.events.single.parameters['duration_minutes'], 45);
      expect(sink.events.single.parameters['has_reminder'], isTrue);
    },
  );

  test(
    'analytics service rejects user-content event names keys and values',
    () async {
      final service = AnalyticsService(RecordingAnalyticsSink());

      expect(
        () => service.logEvent('search_query'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => service.logEvent(
          'task_created',
          parameters: {'task_title': 'Write report'},
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => service.logEvent(
          'task_created',
          parameters: {'label': 'Write report'},
        ),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test(
    'firebase analytics sink logs only validated primitive parameters',
    () async {
      final logged = <AnalyticsEvent>[];
      final sink = FirebaseAnalyticsSink(
        logEvent: (name, parameters) async {
          logged.add(AnalyticsEvent(name, parameters));
        },
      );
      final service = AnalyticsService(sink);

      await service.logEvent(
        'task_created',
        parameters: {
          'scheduled_days_ahead': 2,
          'has_time': true,
          'ignored_null': null,
        },
      );

      expect(logged, hasLength(1));
      expect(logged.single.name, 'task_created');
      expect(logged.single.parameters, {
        'scheduled_days_ahead': 2,
        'has_time': 1,
      });
    },
  );

  test(
    'default firebase analytics sink no-ops when Firebase is not initialized',
    () async {
      final sink = FirebaseAnalyticsSink();
      final service = AnalyticsService(sink);

      await service.logEvent(
        'task_created',
        parameters: {'has_schedule': true},
      );
    },
  );

  test('analytics sink failures do not escape app flows', () async {
    final service = AnalyticsService(_ThrowingAnalyticsSink());

    await service.logEvent('task_created', parameters: {'has_schedule': true});
  });

  test('route analytics maps safe screen names and ignores query text', () {
    expect(AppAnalytics.screenNameForUri(Uri.parse('/splash')), 'splash');
    expect(
      AppAnalytics.screenNameForUri(Uri.parse('/onboarding')),
      'onboarding',
    );
    expect(AppAnalytics.screenNameForUri(Uri.parse('/today')), 'today');
    expect(
      AppAnalytics.screenNameForUri(Uri.parse('/today/search?q=private')),
      'search',
    );
    expect(AppAnalytics.screenNameForUri(Uri.parse('/upcoming')), 'upcoming');
    expect(AppAnalytics.screenNameForUri(Uri.parse('/lists')), 'lists');
    expect(AppAnalytics.screenNameForUri(Uri.parse('/lists/all')), 'lists_all');
    expect(
      AppAnalytics.screenNameForUri(Uri.parse('/lists/completed')),
      'lists_completed',
    );
    expect(
      AppAnalytics.screenNameForUri(Uri.parse('/lists/inbox')),
      'lists_inbox',
    );
    expect(
      AppAnalytics.screenNameForUri(Uri.parse('/lists/folder/42?name=Work')),
      'folder_detail',
    );
    expect(
      AppAnalytics.screenNameForUri(Uri.parse('/lists/reminders')),
      'reminders',
    );
    expect(
      AppAnalytics.screenNameForUri(Uri.parse('/lists/insights')),
      'insights',
    );
    expect(AppAnalytics.screenNameForUri(Uri.parse('/settings')), 'settings');
    expect(AppAnalytics.screenNameForUri(Uri.parse('/quick-add')), 'quick_add');
    expect(AppAnalytics.screenNameForUri(Uri.parse('/focus')), isNull);
    expect(AppAnalytics.screenNameForUri(Uri.parse('/unknown')), isNull);
  });

  test('route tracker deduplicates consecutive screen views', () async {
    final loggedScreens = <String>[];
    final tracker = AppAnalyticsRouteTracker(
      logScreenView: (screenName) async {
        loggedScreens.add(screenName);
      },
    );

    await tracker.track(Uri.parse('/today'));
    await tracker.track(Uri.parse('/today?ignored=user-text'));
    await tracker.track(Uri.parse('/lists'));
    await tracker.track(Uri.parse('/lists/folder/7'));
    await tracker.track(Uri.parse('/lists/folder/8'));
    await tracker.track(Uri.parse('/focus'));

    expect(loggedScreens, ['today', 'lists', 'folder_detail']);
  });

  test('task controller logs safe task lifecycle analytics', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final sink = RecordingAnalyticsSink();
    final controller = TaskController(
      TaskRepository(db),
      null,
      AnalyticsService(sink),
    );

    final taskId = await controller.create(
      TaskDraft(
        title: 'Private task title',
        scheduledDate: DateTime(2026, 9, 9),
        scheduledTime: DateTime(2026, 9, 9, 10),
        reminderTime: DateTime(2026, 9, 9, 9),
      ),
    );
    await controller.complete(taskId);

    expect(sink.events.map((event) => event.name), [
      'task_created',
      'task_completed',
    ]);
    expect(sink.events.first.parameters, {
      'has_schedule': true,
      'has_time': true,
      'has_reminder': true,
      'has_repeat': false,
    });
    expect(sink.events.last.parameters, {'generated_successor': false});
    expect(sink.events.toString(), isNot(contains('Private task title')));
  });

  test('folder repository logs folder creation without folder names', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final sink = RecordingAnalyticsSink();
    final repository = FolderRepository(
      db,
      analyticsService: AnalyticsService(sink),
    );

    await repository.createFolder('Private folder name');

    expect(sink.events.map((event) => event.name), ['folder_created']);
    expect(sink.events.single.parameters, {'is_inbox': false});
    expect(sink.events.toString(), isNot(contains('Private folder name')));
  });
}

class _ThrowingAnalyticsSink implements AnalyticsSink {
  @override
  Future<void> log(AnalyticsEvent event) {
    throw StateError('analytics transport failed');
  }
}
