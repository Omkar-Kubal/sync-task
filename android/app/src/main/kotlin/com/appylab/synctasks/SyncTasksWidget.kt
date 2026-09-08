package com.appylab.synctasks

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class SyncTasksWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        Log.d(TAG, "onUpdate: ids=${appWidgetIds.toList()}")
        appWidgetIds.forEach { updateWidget(context, appWidgetManager, it) }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        val minW = newOptions.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, -1)
        val minH = newOptions.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, -1)
        Log.d(TAG, "onAppWidgetOptionsChanged: id=$appWidgetId minW=$minW minH=$minH")
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    companion object {
        private const val TAG = "SyncTasksWidget"
        private const val PREFS_NAME = "HomeWidgetPreferences"

        private val TODAY_URI = Uri.parse("synctasks://today")

        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            Log.d(TAG, "updateWidget: id=$appWidgetId")

            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val countStr = prefs.getString("widget_tasks_count", "0") ?: "0"
            val countText = prefs.getString("widget_tasks_count_text", "0 tasks left") ?: "0 tasks left"
            val todayHeader = prefs.getString("widget_today_header", "Today, 0 tasks left") ?: "Today, 0 tasks left"

            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
            val isMedium = minWidth >= 180
            val layoutId = if (isMedium) R.layout.widget_medium else R.layout.widget_small

            try {
                val views = RemoteViews(context.packageName, layoutId)

                if (isMedium) {
                    views.setTextViewText(R.id.widget_header_text, todayHeader)

                    val t1Title = prefs.getString("widget_task1_title", "") ?: ""
                    val t1Time = prefs.getString("widget_task1_time", "") ?: ""
                    val t2Title = prefs.getString("widget_task2_title", "") ?: ""
                    val t2Time = prefs.getString("widget_task2_time", "") ?: ""
                    val moreText = prefs.getString("widget_more_text", "") ?: ""

                    bindTaskRow(views, R.id.widget_task1_row, R.id.widget_task1_title, R.id.widget_task1_time, t1Title, t1Time)
                    bindTaskRow(views, R.id.widget_task2_row, R.id.widget_task2_title, R.id.widget_task2_time, t2Title, t2Time)
                    views.setViewVisibility(R.id.widget_more_row, if (moreText.isNotEmpty()) View.VISIBLE else View.GONE)
                    views.setTextViewText(R.id.widget_more_text, moreText)

                    val hasTasks = t1Title.isNotEmpty() || t2Title.isNotEmpty()
                    views.setViewVisibility(R.id.widget_empty_view, if (hasTasks) View.GONE else View.VISIBLE)
                    views.setViewVisibility(R.id.widget_task_list, if (hasTasks) View.VISIBLE else View.GONE)
                } else {
                    val label = if (countStr == "1") "1 task" else "$countStr tasks"
                    views.setTextViewText(R.id.widget_count_title, label)
                    views.setTextViewText(R.id.widget_subtext, "Today")
                }

                val todayIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    TODAY_URI,
                )

                val quickAddIntent = PendingIntent.getActivity(
                    context,
                    201,
                    Intent(context, QuickAddActivity::class.java).apply {
                        addFlags(
                            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP,
                        )
                    },
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )

                views.setOnClickPendingIntent(R.id.widget_container, todayIntent)
                views.setOnClickPendingIntent(R.id.widget_add_btn, quickAddIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "updateAppWidget OK")
            } catch (e: Exception) {
                Log.e(TAG, "updateAppWidget FAILED: ${e.javaClass.simpleName}: ${e.message}", e)
            }
        }

        private fun bindTaskRow(
            views: RemoteViews,
            rowId: Int,
            titleId: Int,
            timeId: Int,
            title: String,
            time: String,
        ) {
            if (title.isNotEmpty()) {
                views.setViewVisibility(rowId, View.VISIBLE)
                views.setTextViewText(titleId, title)
                if (time.isNotEmpty()) {
                    views.setViewVisibility(timeId, View.VISIBLE)
                    views.setTextViewText(timeId, time)
                } else {
                    views.setViewVisibility(timeId, View.GONE)
                }
            } else {
                views.setViewVisibility(rowId, View.GONE)
            }
        }
    }
}

