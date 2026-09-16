import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../features/tasks/data/task_repository.dart';

/// Writes the latest today's task data to shared storage for the native
/// Android widget, then requests a widget UI update.
abstract final class WidgetDataUpdater {
  static const _tag = 'WidgetDataUpdater';
  static const androidWidgetNames = <String>[
    'SyncTasksProgressWidget',
    'SyncTasksInboxWidget',
    'SyncTasksTodayWidget',
  ];

  static Future<void> update(TaskRepository repository) async {
    _log('update: start');
    try {
      final todayTasks = await repository.listTodayTasks();
      final completedToday = await repository.listCompletedTasksForLocalDay(
        DateTime.now(),
      );
      final count = todayTasks.length;
      final completedCount = completedToday.length;
      final totalCount = count + completedCount;
      _log('update: todayTasksCount=$count');

      final countText = count == 1 ? '1 task left' : '$count tasks left';
      final headerText = 'Today, $countText';
      final progressText = totalCount == 0
          ? '0/0'
          : '$completedCount/$totalCount';
      final progressSubtext = completedCount == 1
          ? '1 done today'
          : '$completedCount done today';

      await HomeWidget.saveWidgetData<String>('widget_tasks_count', '$count');
      await HomeWidget.saveWidgetData<String>(
        'widget_tasks_completed_count',
        '$completedCount',
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_tasks_total_count',
        '$totalCount',
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_progress_text',
        progressText,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_progress_subtext',
        progressSubtext,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_tasks_count_text',
        countText,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_today_header',
        headerText,
      );

      const visibleTaskRows = 6;
      for (var i = 0; i < visibleTaskRows; i++) {
        final key = 'widget_task${i + 1}';
        if (i < todayTasks.length) {
          final task = todayTasks[i];
          final title = task.title;
          final time = task.scheduledTime != null
              ? DateFormat('H:mm').format(task.scheduledTime!)
              : '';
          await HomeWidget.saveWidgetData<String>('${key}_id', '${task.id}');
          await HomeWidget.saveWidgetData<String>('${key}_title', title);
          await HomeWidget.saveWidgetData<String>('${key}_time', time);
          _log('update: saved $key hasTime=${time.isNotEmpty}');
        } else {
          await HomeWidget.saveWidgetData<String>('${key}_id', '');
          await HomeWidget.saveWidgetData<String>('${key}_title', '');
          await HomeWidget.saveWidgetData<String>('${key}_time', '');
        }
      }

      final moreCount = count > visibleTaskRows ? count - visibleTaskRows : 0;
      await HomeWidget.saveWidgetData<String>(
        'widget_more_count',
        '$moreCount',
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_more_text',
        moreCount > 0 ? '+$moreCount more today' : '',
      );

      for (final androidWidgetName in androidWidgetNames) {
        _log(
          'update: calling HomeWidget.updateWidget(androidName=$androidWidgetName)',
        );
        await HomeWidget.updateWidget(androidName: androidWidgetName);
      }
      _log('update: done');
    } catch (error, stackTrace) {
      _log('update: ERROR $error', error: error, stackTrace: stackTrace);
    }
  }

  static void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    dev.log(message, name: _tag, error: error, stackTrace: stackTrace);
  }
}
