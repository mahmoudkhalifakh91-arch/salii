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
        BlockPrefs.lockToggledAppsNow(context)
        SalliAccessibilityService.instance?.forceHomeIfCurrentAppBlocked()
    }
}
