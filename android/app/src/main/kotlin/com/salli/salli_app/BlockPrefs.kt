package com.salli.salli_app

import android.content.Context
import android.content.SharedPreferences

/**
 * تخزين بسيط ومشترك بين MainActivity و SalliAccessibilityService و
 * PrayerBlockReceiver لحالة "التطبيقات المحددة للتقييد" و"التطبيقات
 * المقفولة فعلياً حالياً". بنستخدم ملف SharedPreferences مستقل
 * (مش الملف الافتراضي بتاع shared_preferences في Flutter) عشان الاعتماد
 * يكون واضح ومباشر عن طريق الـ MethodChannel بس.
 */
object BlockPrefs {
    private const val PREFS_NAME = "salli_block_prefs"
    private const val KEY_TOGGLED_APPS = "toggled_apps"
    private const val KEY_LOCKED_APPS = "locked_apps"

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun setToggledApps(context: Context, packages: Set<String>) {
        prefs(context).edit().putStringSet(KEY_TOGGLED_APPS, packages).apply()
    }

    fun getToggledApps(context: Context): Set<String> =
        prefs(context).getStringSet(KEY_TOGGLED_APPS, emptySet()) ?: emptySet()

    fun setLockedApps(context: Context, packages: Set<String>) {
        prefs(context).edit().putStringSet(KEY_LOCKED_APPS, packages).apply()
    }

    fun getLockedApps(context: Context): Set<String> =
        prefs(context).getStringSet(KEY_LOCKED_APPS, emptySet()) ?: emptySet()

    /** لحظة الأذان: كل تطبيق محدد يبقى "مقفول" فورًا. */
    fun lockToggledAppsNow(context: Context) {
        setLockedApps(context, getToggledApps(context))
    }

    /** إلغاء قفل تطبيق معين يدويًا من شاشة الإعدادات داخل صلّي. */
    fun unlockApp(context: Context, packageName: String) {
        val locked = getLockedApps(context).toMutableSet()
        locked.remove(packageName)
        setLockedApps(context, locked)

        val toggled = getToggledApps(context).toMutableSet()
        toggled.remove(packageName)
        setToggledApps(context, toggled)
    }
}
