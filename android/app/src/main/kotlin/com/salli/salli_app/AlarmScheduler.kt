package com.salli.salli_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

/**
 * جدولة منبهات الأذان وقفل التطبيقات. بتحفظ آخر جدول في SharedPreferences
 * عشان BootReceiver يقدر يرجّعها بعد إعادة تشغيل الجهاز (AlarmManager
 * بيمسح كل المنبهات عند الريستارت).
 */
object AlarmScheduler {
    private const val PREFS = "salli_alarm_schedule"
    private const val KEY_ADHAN = "adhan"
    private const val KEY_ADHAN_MUEZZIN = "adhan_muezzin"
    private const val KEY_BLOCKS = "blocks"

    private const val BLOCK_BASE = 9000
    private const val UNLOCK_BASE = 9200
    private const val ADHAN_BASE = 9400
    private const val MAX_SLOTS = 100

    private fun canScheduleExact(context: Context, am: AlarmManager): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.S || am.canScheduleExactAlarms()

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun toJson(items: List<Map<*, *>>): String {
        val arr = JSONArray()
        items.forEach { item ->
            val millis = (item["millis"] as? Number)?.toLong() ?: return@forEach
            arr.put(JSONObject().put("millis", millis).put("name", item["name"] as? String ?: ""))
        }
        return arr.toString()
    }

    private fun fromJson(json: String?): List<Map<*, *>> {
        if (json.isNullOrEmpty()) return emptyList()
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).map {
                val o = arr.getJSONObject(it)
                mapOf("millis" to o.getLong("millis"), "name" to o.optString("name"))
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun cancelRange(context: Context, receiver: Class<*>, base: Int) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (i in 0 until MAX_SLOTS) {
            val pending = PendingIntent.getBroadcast(
                context, base + i, Intent(context, receiver),
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            ) ?: continue
            am.cancel(pending)
            pending.cancel()
        }
    }

    fun cancelAdhanAlerts(context: Context) {
        cancelRange(context, AdhanAlarmReceiver::class.java, ADHAN_BASE)
        prefs(context).edit().remove(KEY_ADHAN).remove(KEY_ADHAN_MUEZZIN).apply()
    }

    fun cancelPrayerBlocks(context: Context) {
        cancelRange(context, PrayerBlockReceiver::class.java, BLOCK_BASE)
        cancelRange(context, PrayerAutoUnlockReceiver::class.java, UNLOCK_BASE)
        prefs(context).edit().remove(KEY_BLOCKS).apply()
    }

    fun schedulePrayerBlocks(context: Context, items: List<Map<*, *>>, persist: Boolean = true) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (!canScheduleExact(context, am)) return
        cancelRange(context, PrayerBlockReceiver::class.java, BLOCK_BASE)
        cancelRange(context, PrayerAutoUnlockReceiver::class.java, UNLOCK_BASE)
        if (persist) prefs(context).edit().putString(KEY_BLOCKS, toJson(items)).apply()

        val now = System.currentTimeMillis()
        items.take(MAX_SLOTS).forEachIndexed { index, item ->
            val millis = (item["millis"] as? Number)?.toLong() ?: return@forEachIndexed
            val name = item["name"] as? String ?: ""
            if (millis <= now) return@forEachIndexed

            val lockIntent = Intent(context, PrayerBlockReceiver::class.java).apply {
                putExtra(PrayerBlockReceiver.EXTRA_PRAYER_NAME, name)
            }
            val lockPending = PendingIntent.getBroadcast(
                context, BLOCK_BASE + index, lockIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, lockPending)

            val unlockPending = PendingIntent.getBroadcast(
                context, UNLOCK_BASE + index, Intent(context, PrayerAutoUnlockReceiver::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            am.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP, millis + 5 * 60 * 1000L, unlockPending
            )
        }
    }

    fun scheduleAdhanAlerts(
        context: Context, items: List<Map<*, *>>, muezzinId: String, persist: Boolean = true
    ) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (!canScheduleExact(context, am)) return
        cancelRange(context, AdhanAlarmReceiver::class.java, ADHAN_BASE)
        if (persist) {
            prefs(context).edit()
                .putString(KEY_ADHAN, toJson(items))
                .putString(KEY_ADHAN_MUEZZIN, muezzinId)
                .apply()
        }

        val now = System.currentTimeMillis()
        items.take(MAX_SLOTS).forEachIndexed { index, item ->
            val millis = (item["millis"] as? Number)?.toLong() ?: return@forEachIndexed
            val name = item["name"] as? String ?: ""
            if (millis <= now) return@forEachIndexed

            val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
                putExtra(AdhanAlarmReceiver.EXTRA_PRAYER_NAME, name)
                putExtra(AdhanAlarmReceiver.EXTRA_MUEZZIN_ID, muezzinId)
            }
            val pending = PendingIntent.getBroadcast(
                context, ADHAN_BASE + index, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, pending)
        }
    }

    /** بعد الريستارت (أو تحديث التطبيق): نرجّع آخر جدول محفوظ. */
    fun restoreAll(context: Context) {
        val p = prefs(context)
        val adhan = fromJson(p.getString(KEY_ADHAN, null))
        if (adhan.isNotEmpty()) {
            scheduleAdhanAlerts(
                context, adhan, p.getString(KEY_ADHAN_MUEZZIN, null) ?: "abdul_basit", persist = false
            )
        }
        val blocks = fromJson(p.getString(KEY_BLOCKS, null))
        if (blocks.isNotEmpty()) schedulePrayerBlocks(context, blocks, persist = false)
    }
}
