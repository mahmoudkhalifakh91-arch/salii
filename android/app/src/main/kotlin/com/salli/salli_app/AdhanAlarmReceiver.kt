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
 * بتتفعل بالظبط لحظة دخول وقت كل صلاة، وبتفتح شاشة أذان كاملة الشاشة
 * (حتى لو الهاتف مقفول) بتشغل صوت الأذان الفعلي، مش مجرد نغمة إشعار
 * قصيرة. الطريقة الرسمية والمضمونة لفتح شاشة كاملة من الخلفية في
 * أندرويد هي full-screen intent notification (نفس طريقة تطبيقات المنبه).
 */
class AdhanAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_PRAYER_NAME = "prayer_name"
        const val EXTRA_MUEZZIN_ID = "muezzin_id"
        private const val CHANNEL_ID = "adhan_alert_channel"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "الصلاة"
        val muezzinId = intent.getStringExtra(EXTRA_MUEZZIN_ID) ?: "makkah"

        val fullScreenIntent = Intent(context, AdhanAlertActivity::class.java).apply {
            putExtra(EXTRA_PRAYER_NAME, prayerName)
            putExtra(EXTRA_MUEZZIN_ID, muezzinId)
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context, 9600, fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "تنبيه الأذان", NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "شاشة الأذان اللي بتفتح وتشغل الصوت وقت كل صلاة"
                // الصوت بيتشغل من داخل شاشة الأذان نفسها (MediaPlayer)، مش
                // من الإشعار، عشان نتحكم فيه (إيقاف/إعادة) ومنعش صوتين مع بعض.
                setSound(null, null)
                enableVibration(true)
            }
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("حان الآن وقت أذان $prayerName")
            .setContentText("اضغط لفتح شاشة الأذان")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setContentIntent(fullScreenPendingIntent)
            .setAutoCancel(true)
            .build()

        manager.notify(9600, notification)

        // على الأجهزة اللي بتسمح ببدء نشاط من الخلفية مباشرة (مثلاً لو
        // تطبيق صلّي أصلاً في المقدمة وقت الأذان)، نجرب نفتح الشاشة فورًا
        // كمان كـ طبقة أمان إضافية فوق الإشعار.
        try {
            context.startActivity(fullScreenIntent)
        } catch (_: Exception) {
            // متوقع يفشل من الخلفية على أندرويد الحديث؛ الإشعار كافي وقتها
        }
    }
}
