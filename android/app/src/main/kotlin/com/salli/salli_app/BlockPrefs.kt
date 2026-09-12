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
    private const val KEY_CURRENT_PRAYER_NAME = "current_prayer_name"
    private const val KEY_ADHAN_TIMESTAMP = "adhan_timestamp"

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

    /** لحظة الأذان: كل تطبيق محدد يبقى "مقفول"، ونسجل اسم الصلاة ولحظة الأذان. */
    fun lockToggledAppsNow(context: Context, prayerNameAr: String) {
        setLockedApps(context, getToggledApps(context))
        prefs(context).edit()
            .putString(KEY_CURRENT_PRAYER_NAME, prayerNameAr)
            .putLong(KEY_ADHAN_TIMESTAMP, System.currentTimeMillis())
            .apply()
    }

    fun getCurrentPrayerName(context: Context): String =
        prefs(context).getString(KEY_CURRENT_PRAYER_NAME, "") ?: ""

    fun getAdhanTimestamp(context: Context): Long =
        prefs(context).getLong(KEY_ADHAN_TIMESTAMP, 0L)

    /**
     * إنهاء جلسة القفل الحالية بس (سواء المستخدم أكّد إنه صلّى، أو خلصت
     * مهلة الـ 5 دقايق تلقائيًا). التطبيقات ترجع تشتغل دلوقتي، لكن
     * تفضل "محددة" في الإعدادات وهترجع تتقفل تاني مع الأذان الجاي.
     */
    fun endCurrentBlockSession(context: Context) {
        setLockedApps(context, emptySet())
    }

    /** إلغاء تحديد تطبيق نهائيًا من شاشة الإعدادات (مش هيتقفل تاني خالص). */
    fun unlockApp(context: Context, packageName: String) {
        val locked = getLockedApps(context).toMutableSet()
        locked.remove(packageName)
        setLockedApps(context, locked)

        val toggled = getToggledApps(context).toMutableSet()
        toggled.remove(packageName)
        setToggledApps(context, toggled)
    }
}
