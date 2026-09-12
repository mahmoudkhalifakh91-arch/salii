package com.salli.salli_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

/**
 * بتتفعل تلقائيًا بعد 5 دقايق بالظبط من كل أذان. لو المستخدم مأكدش إنه
 * صلّى (يعني لسه في جلسة قفل شغالة)، بتسيب التطبيقات تشتغل تاني من غير
 * أي تدخل من المستخدم، وبتبعت إشعار تذكير بالآية الكريمة.
 */
class PrayerAutoUnlockReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // لو المستخدم أكّد الصلاة بنفسه قبل كده، جلسة القفل خلصت أصلاً
        // ومفيش داعي نبعت إشعار "فاتتك الصلاة" غير لو لسه فعلاً مقفول.
        val stillLocked = BlockPrefs.getLockedApps(context).isNotEmpty()
        BlockPrefs.endCurrentBlockSession(context)
        if (stillLocked) {
            showReminderNotification(context)
        }
    }

    private fun showReminderNotification(context: Context) {
        val channelId = "prayer_auto_unlock_channel"
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "تذكير الصلاة",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "تذكير بعد انتهاء مهلة قفل التطبيقات وقت الصلاة"
            }
            manager.createNotificationChannel(channel)
        }

        val openAppIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent = PendingIntent.getActivity(
            context, 9500, openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("إن الصلاة كانت على المؤمنين كتابًا موقوتًا")
            .setContentText("اتفتحت التطبيقات تاني، متنساش تقضي الصلاة لو لسه ماصليتش")
            .setStyle(NotificationCompat.BigTextStyle().bigText(
                "«إن الصلاة كانت على المؤمنين كتابًا موقوتًا» — اتفتحت التطبيقات المقفولة تاني تلقائيًا، متنساش تقضي الصلاة لو لسه ماصليتش."
            ))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        manager.notify(9500, notification)
    }
}
