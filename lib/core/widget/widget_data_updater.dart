import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../features/tasks/data/task_repository.dart';

/// Writes the latest today's task data to shared storage for the native
/// Android widget, then requests a widget UI update.
abstract final class WidgetDataUpdater {
  static const _tag = 'WidgetDataUpdater';
  static const _androidWidgetName = 'SyncTasksWidget';

  static Future<void> update(TaskRepository repository) async {
    _log('update: start');
    try {
      final todayTasks = await repository.listTodayTasks();
      final count = todayTasks.length;
      _log('update: todayTasksCount=$count');

      final countText = count == 1 ? '1 task left' : '$count tasks left';
      final headerText = 'Today, $countText';

      await HomeWidget.saveWidgetData<String>('widget_tasks_count', '$count');
      await HomeWidget.saveWidgetData<String>(
        'widget_tasks_count_text',
        countText,
      );
      await HomeWidget.saveWidgetData<String>(
        'widget_today_header',
        headerText,
      );

      final visibleTaskRows = count > 2 ? 1 : 2;
      for (var i = 0; i < 3; i++) {
        final key = 'widget_task${i + 1}';
        if (i < visibleTaskRows && i < todayTasks.length) {
          final task = todayTasks[i];
          final title = task.title;
          final time = task.scheduledTime != null
              ? DateFormat('H:mm').format(task.scheduledTime!)
              : '';
          await HomeWidget.saveWidgetData<String>('${key}_title', title);
          await HomeWidget.saveWidgetData<String>('${key}_time', time);
          _log('update: saved ${key}_title=$title ${key}_time=$time');
        } else {
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

      _log(
        'update: calling HomeWidget.updateWidget(androidName=$_androidWidgetName)',
      );
      await HomeWidget.updateWidget(androidName: _androidWidgetName);
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



