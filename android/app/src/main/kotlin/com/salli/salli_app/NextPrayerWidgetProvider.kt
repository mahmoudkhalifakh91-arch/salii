package com.salli.salli_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * ودجت الشاشة الرئيسية اللي بتعرض "الصلاة القادمة" ووقتها بدون ما
 * المستخدم يحتاج يفتح التطبيق خالص. البيانات بييجي من PrayerWidgetPrefs
 * اللي بتحدّثها Flutter كل ما تحسب مواقيت اليوم، وكمان بتتحدث فورًا لحظة
 * كل أذان (عن طريق AdhanAlarmReceiver) عشان تتغير للصلاة اللي بعدها فورًا.
 */
class NextPrayerWidgetProvider : AppWidgetProvider() {

    companion object {
        /** يُستدعى من أي مكان في التطبيق (Flutter عن طريق MainActivity، أو
         * AdhanAlarmReceiver لحظة الأذان) لتحديث كل نسخ الودجت المضافة. */
        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                android.content.ComponentName(context, NextPrayerWidgetProvider::class.java)
            )
            if (ids.isNotEmpty()) {
                val provider = NextPrayerWidgetProvider()
                for (id in ids) {
                    provider.updateWidget(context, manager, id)
                }
            }
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    private fun updateWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.widget_next_prayer)
        val next = PrayerWidgetPrefs.nextPrayer(context)

        if (next == null) {
            views.setTextViewText(R.id.widgetPrayerName, "افتح التطبيق")
            views.setTextViewText(R.id.widgetPrayerTime, "")
            views.setTextViewText(R.id.widgetRemaining, "لتحديث مواقيت الصلاة")
        } else {
            val timeFormat = SimpleDateFormat("h:mm a", Locale("ar"))
            views.setTextViewText(R.id.widgetPrayerName, next.nameAr)
            views.setTextViewText(R.id.widgetPrayerTime, timeFormat.format(Date(next.epochMillis)))

            val remainingMs = (next.epochMillis - System.currentTimeMillis()).coerceAtLeast(0)
            val totalMinutes = remainingMs / 60000
            val hours = totalMinutes / 60
            val minutes = totalMinutes % 60
            views.setTextViewText(
                R.id.widgetRemaining,
                if (hours > 0) "متبقي ${hours} س ${minutes} د" else "متبقي ${minutes} د"
            )
        }

        // الضغط على الودجت يفتح التطبيق مباشرة
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 9700, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widgetRoot, pendingIntent)

        manager.updateAppWidget(widgetId, views)
    }
}
