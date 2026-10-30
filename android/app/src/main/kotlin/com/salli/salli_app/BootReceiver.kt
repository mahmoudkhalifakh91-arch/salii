package com.salli.salli_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** يرجّع منبهات الأذان وقفل التطبيقات بعد إعادة تشغيل الجهاز أو تحديث التطبيق. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON" -> {
                try {
                    AlarmScheduler.restoreAll(context)
                } catch (_: Exception) {
                }
            }
        }
    }
}
