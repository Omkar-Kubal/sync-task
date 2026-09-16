package com.appylab.synctasks

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class SyncTasksProgressWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        WidgetRenderer.updateAll(context, appWidgetManager, appWidgetIds, WidgetKind.PROGRESS)
    }
}

class SyncTasksInboxWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        WidgetRenderer.updateAll(context, appWidgetManager, appWidgetIds, WidgetKind.INBOX)
    }
}

class SyncTasksTodayWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        WidgetRenderer.updateAll(context, appWidgetManager, appWidgetIds, WidgetKind.TODAY)
    }
}

private enum class WidgetKind {
    PROGRESS,
    INBOX,
    TODAY,
}

private object WidgetRenderer {
    private const val TAG = "SyncTasksWidget"
    private const val PREFS_NAME = "HomeWidgetPreferences"

    private val TODAY_URI = Uri.parse("synctasks://today")

    fun updateAll(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        kind: WidgetKind,
    ) {
        Log.d(TAG, "onUpdate: kind=$kind ids=${appWidgetIds.toList()}")
        appWidgetIds.forEach { updateWidget(context, appWidgetManager, it, kind) }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        kind: WidgetKind,
    ) {
        Log.d(TAG, "updateWidget: kind=$kind id=$appWidgetId")

        try {
            val views = when (kind) {
                WidgetKind.PROGRESS -> progressViews(context)
                WidgetKind.INBOX -> inboxViews(context)
                WidgetKind.TODAY -> todayViews(context)
            }

            val todayIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                TODAY_URI,
            )
            views.setOnClickPendingIntent(R.id.widget_container, todayIntent)

            if (kind == WidgetKind.INBOX) {
                val intent = quickAddIntent(context)
                views.setOnClickPendingIntent(R.id.widget_container, intent)
                views.setOnClickPendingIntent(R.id.widget_add_btn, intent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
            Log.d(TAG, "updateAppWidget OK")
        } catch (e: Exception) {
            Log.e(TAG, "updateAppWidget FAILED: ${e.javaClass.simpleName}: ${e.message}", e)
        }
    }

    private fun progressViews(context: Context): RemoteViews {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, R.layout.widget_progress)
        views.setTextViewText(
            R.id.widget_progress_text,
            prefs.getString("widget_progress_text", "0/0") ?: "0/0",
        )
        views.setTextViewText(
            R.id.widget_progress_subtext,
            prefs.getString("widget_progress_subtext", "today") ?: "today",
        )
        return views
    }

    private fun inboxViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_inbox)
        views.setTextViewText(R.id.widget_inbox_subtext, "Quick add")
        return views
    }

    private fun todayViews(context: Context): RemoteViews {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, R.layout.widget_today)
        val progressText = prefs.getString("widget_progress_text", "0/0") ?: "0/0"
        val moreText = prefs.getString("widget_more_text", "") ?: ""

        views.setTextViewText(R.id.widget_header_count, "$progressText done")

        val rows = listOf(
            TaskRowIds(R.id.widget_task1_row, R.id.widget_task1_checkbox, R.id.widget_task1_title, R.id.widget_task1_time),
            TaskRowIds(R.id.widget_task2_row, R.id.widget_task2_checkbox, R.id.widget_task2_title, R.id.widget_task2_time),
            TaskRowIds(R.id.widget_task3_row, R.id.widget_task3_checkbox, R.id.widget_task3_title, R.id.widget_task3_time),
            TaskRowIds(R.id.widget_task4_row, R.id.widget_task4_checkbox, R.id.widget_task4_title, R.id.widget_task4_time),
            TaskRowIds(R.id.widget_task5_row, R.id.widget_task5_checkbox, R.id.widget_task5_title, R.id.widget_task5_time),
            TaskRowIds(R.id.widget_task6_row, R.id.widget_task6_checkbox, R.id.widget_task6_title, R.id.widget_task6_time),
        )

        var hasTasks = false
        rows.forEachIndexed { index, rowIds ->
            val key = "widget_task${index + 1}"
            val taskId = prefs.getString("${key}_id", "") ?: ""
            val title = prefs.getString("${key}_title", "") ?: ""
            val time = prefs.getString("${key}_time", "") ?: ""
            hasTasks = hasTasks || title.isNotEmpty()
            bindTaskRow(context, views, rowIds, taskId, title, time)
        }

        views.setViewVisibility(R.id.widget_more_row, if (moreText.isNotEmpty()) View.VISIBLE else View.GONE)
        views.setTextViewText(R.id.widget_more_text, moreText)
        views.setViewVisibility(R.id.widget_empty_view, if (hasTasks) View.GONE else View.VISIBLE)
        views.setViewVisibility(R.id.widget_task_list, if (hasTasks) View.VISIBLE else View.GONE)
        return views
    }

    private fun bindTaskRow(
        context: Context,
        views: RemoteViews,
        rowIds: TaskRowIds,
        taskId: String,
        title: String,
        time: String,
    ) {
        if (title.isNotEmpty()) {
            views.setViewVisibility(rowIds.rowId, View.VISIBLE)
            views.setTextViewText(rowIds.titleId, title)
            if (taskId.isNotEmpty()) {
                views.setOnClickPendingIntent(
                    rowIds.checkboxId,
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("synctasks://toggle-task?taskId=$taskId"),
                    ),
                )
            }
            if (time.isNotEmpty()) {
                views.setViewVisibility(rowIds.timeId, View.VISIBLE)
                views.setTextViewText(rowIds.timeId, time)
            } else {
                views.setViewVisibility(rowIds.timeId, View.GONE)
            }
        } else {
            views.setViewVisibility(rowIds.rowId, View.GONE)
        }
    }

    private fun quickAddIntent(context: Context): PendingIntent {
        return PendingIntent.getActivity(
            context,
            201,
            Intent(context, QuickAddActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP,
                )
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}

private data class TaskRowIds(
    val rowId: Int,
    val checkboxId: Int,
    val titleId: Int,
    val timeId: Int,
)
