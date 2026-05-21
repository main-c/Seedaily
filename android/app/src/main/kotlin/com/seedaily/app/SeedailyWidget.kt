package com.seedaily.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class SeedailyWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val TAG = "SeedailyWidget"
        private val GOLD = Color.parseColor("#EF9D10")
        // 35% white for unread days (replaces setFloat alpha)
        private val DAY_INACTIVE = Color.argb(90, 255, 255, 255)
        private val DAY_IDS = listOf(
            R.id.day_0, R.id.day_1, R.id.day_2,
            R.id.day_3, R.id.day_4, R.id.day_5, R.id.day_6
        )
        private val DAY_LABELS = listOf("L", "M", "M", "J", "V", "S", "D")

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            try {
                val views = RemoteViews(context.packageName, R.layout.seedaily_widget)
                val prefs = HomeWidgetPlugin.getData(context)

                val passage = prefs.getString("widget_passage", null)
                // streak stored as String for cross-platform type safety
                val streakRaw = prefs.getString("widget_streak_count", null)
                val streak = streakRaw?.toIntOrNull()
                    ?: try { prefs.getInt("widget_streak_count", 0) } catch (e: ClassCastException) { 0 }
                val message     = prefs.getString("widget_message", "Prêt pour ta lecture du jour ?")
                val isRead      = prefs.getBoolean("widget_is_read", false)
                val weekDays    = prefs.getString("widget_week_days", "0000000") ?: "0000000"
                val isToday     = prefs.getBoolean("widget_is_today", true)

                // Flame icon — set programmatically to avoid VectorDrawable XML inflation issues
                try {
                    views.setImageViewResource(R.id.widget_flame_icon, R.drawable.ic_flame)
                } catch (e: Exception) {
                    Log.w(TAG, "Could not set flame icon: ${e.message}")
                }

                // Streak
                views.setTextViewText(R.id.widget_streak_count, streak.toString())

                // Message
                views.setTextViewText(R.id.widget_message, message ?: "Prêt pour ta lecture du jour ?")

                // Section title + Passage
                if (!passage.isNullOrEmpty()) {
                    val sectionTitle = if (isToday) "Pour aujourd'hui" else "Prochain passage"
                    views.setTextViewText(R.id.widget_section_title, sectionTitle)
                    views.setViewVisibility(R.id.widget_section_title, View.VISIBLE)
                    views.setTextViewText(R.id.widget_passage, passage)
                    views.setViewVisibility(R.id.widget_passage, View.VISIBLE)
                    views.setViewVisibility(R.id.widget_empty, View.GONE)
                } else {
                    views.setViewVisibility(R.id.widget_section_title, View.GONE)
                    views.setViewVisibility(R.id.widget_passage, View.GONE)
                    views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                }

                // Badge "Lu"
                views.setViewVisibility(R.id.widget_badge_read, if (isRead) View.VISIBLE else View.GONE)

                // Tracker hebdomadaire — text color encodes alpha, no setFloat needed
                for (i in DAY_IDS.indices) {
                    val completed = i < weekDays.length && weekDays[i] == '1'
                    views.setTextViewText(DAY_IDS[i], if (completed) "✓" else DAY_LABELS[i])
                    views.setTextColor(DAY_IDS[i], if (completed) GOLD else DAY_INACTIVE)
                }

                // Tap → deep link vers le plan actif
                try {
                    val uri = prefs.getString("widget_uri", "/") ?: "/"
                    val intent = Intent(context, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        data = Uri.parse("seedaily://app$uri")
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context, 0, intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
                } catch (e: Exception) {
                    Log.w(TAG, "Failed to set click intent: ${e.message}")
                }

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "Widget updated: streak=$streak passage=$passage isRead=$isRead week=$weekDays")

            } catch (e: Exception) {
                Log.e(TAG, "Error updating widget", e)
            }
        }
    }
}
