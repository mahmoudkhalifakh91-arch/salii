package com.salli.salli_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * بتتفعل عن طريق AlarmManager بالظبط لحظة دخول وقت كل صلاة (حتى لو
 * تطبيق صلّي نفسه مقفول أو مش شغال). بتحوّل كل تطبيق حدده المستخدم
 * لتطبيق "مقفول"، وبتحاول تقفل أي تطبيق منهم لو شغّال في المقدمة دلوقتي.
 */
class PrayerBlockReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: ""
        BlockPrefs.lockToggledAppsNow(context, prayerName)
        SalliAccessibilityService.instance?.blockCurrentForegroundAppIfNeeded()
    }

    companion object {
        const val EXTRA_PRAYER_NAME = "prayer_name"
    }
}
