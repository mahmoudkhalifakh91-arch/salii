package com.salli.salli_app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/**
 * تخزين قائمة الصلوات (اسمها ووقتها بالمللي ثانية) اللي بترسلها Flutter
 * كل ما تحسب مواقيت اليوم، عشان الـ widget يقدر يحدد "الصلاة القادمة"
 * ويعرضها من غير ما يحتاج يشغّل محرك Flutter نفسه.
 */
object PrayerWidgetPrefs {
    private const val PREFS_NAME = "salli_widget_prefs"
    private const val KEY_PRAYERS_JSON = "prayers_json"

    data class WidgetPrayer(val id: String, val nameAr: String, val epochMillis: Long)

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    /** [prayers] كل عنصر Map فيه المفاتيح: id, nameAr, epochMillis */
    fun savePrayers(context: Context, prayers: List<Map<String, Any?>>) {
        val arr = JSONArray()
        for (p in prayers) {
            val obj = JSONObject()
            obj.put("id", p["id"])
            obj.put("nameAr", p["nameAr"])
            obj.put("epochMillis", (p["epochMillis"] as Number).toLong())
            arr.put(obj)
        }
        prefs(context).edit().putString(KEY_PRAYERS_JSON, arr.toString()).apply()
    }

    fun loadPrayers(context: Context): List<WidgetPrayer> {
        val raw = prefs(context).getString(KEY_PRAYERS_JSON, null) ?: return emptyList()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).map { i ->
                val obj = arr.getJSONObject(i)
                WidgetPrayer(
                    id = obj.getString("id"),
                    nameAr = obj.getString("nameAr"),
                    epochMillis = obj.getLong("epochMillis")
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    /** أول صلاة وقتها لسه لم يجيء بعد، بترتيب الوقت. */
    fun nextPrayer(context: Context): WidgetPrayer? {
        val now = System.currentTimeMillis()
        return loadPrayers(context).sortedBy { it.epochMillis }.firstOrNull { it.epochMillis > now }
    }
}
