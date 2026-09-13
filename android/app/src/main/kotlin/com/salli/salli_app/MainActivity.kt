package com.salli.salli_app

import android.app.AlarmManager
import android.app.AppOpsManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "salli/app_block"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasOverlayPermission" -> result.success(hasOverlayPermission())
                    "requestOverlayPermission" -> {
                        requestOverlayPermission()
                        result.success(null)
                    }
                    "isAccessibilityServiceEnabled" ->
                        result.success(isAccessibilityServiceEnabled())
                    "requestAccessibilityPermission" -> {
                        requestAccessibilityPermission()
                        result.success(null)
                    }
                    "hasUsageStatsPermission" -> result.success(hasUsageStatsPermission())
                    "requestUsageStatsPermission" -> {
                        requestUsageStatsPermission()
                        result.success(null)
                    }
                    "setToggledApps" -> {
                        val apps = (call.arguments as? List<*>)
                            ?.mapNotNull { it as? String }
                            ?.toSet() ?: emptySet()
                        BlockPrefs.setToggledApps(applicationContext, apps)
                        result.success(null)
                    }
                    "getToggledApps" ->
                        result.success(BlockPrefs.getToggledApps(applicationContext).toList())
                    "getLockedApps" ->
                        result.success(BlockPrefs.getLockedApps(applicationContext).toList())
                    "unlockApp" -> {
                        val pkg = call.argument<String>("packageName")
                        if (pkg != null) BlockPrefs.unlockApp(applicationContext, pkg)
                        result.success(null)
                    }
                    "schedulePrayerBlocks" -> {
                        val items = (call.arguments as? List<*>)
                            ?.mapNotNull { it as? Map<*, *> } ?: emptyList()
                        schedulePrayerBlocks(items)
                        result.success(null)
                    }
                    "scheduleAdhanAlerts" -> {
                        val args = call.arguments as? Map<*, *>
                        val items = (args?.get("prayers") as? List<*>)
                            ?.mapNotNull { it as? Map<*, *> } ?: emptyList()
                        val muezzinId = args?.get("muezzinId") as? String ?: "abdul_basit"
                        scheduleAdhanAlerts(items, muezzinId)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasOverlayPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expected = "$packageName/${SalliAccessibilityService::class.java.name}"
        val enabled = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabled)
        while (splitter.hasNext()) {
            if (splitter.next().equals(expected, ignoreCase = true)) return true
        }
        return false
    }

    private fun requestAccessibilityPermission() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun schedulePrayerBlocks(items: List<Map<*, *>>) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val canScheduleExact =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()
        if (!canScheduleExact) return

        items.forEachIndexed { index, item ->
            val millis = (item["millis"] as? Number)?.toLong() ?: return@forEachIndexed
            val name = item["name"] as? String ?: ""
            if (millis <= System.currentTimeMillis()) return@forEachIndexed

            val lockIntent = Intent(this, PrayerBlockReceiver::class.java).apply {
                putExtra(PrayerBlockReceiver.EXTRA_PRAYER_NAME, name)
            }
            val lockPending = PendingIntent.getBroadcast(
                this, 9000 + index, lockIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, lockPending)

            val unlockIntent = Intent(this, PrayerAutoUnlockReceiver::class.java)
            val unlockPending = PendingIntent.getBroadcast(
                this, 9200 + index, unlockIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val autoUnlockMillis = millis + 5 * 60 * 1000L
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, autoUnlockMillis, unlockPending)
        }
    }

    private fun scheduleAdhanAlerts(items: List<Map<*, *>>, muezzinId: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val canScheduleExact =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()
        if (!canScheduleExact) return

        items.forEachIndexed { index, item ->
            val millis = (item["millis"] as? Number)?.toLong() ?: return@forEachIndexed
            val name = item["name"] as? String ?: ""
            if (millis <= System.currentTimeMillis()) return@forEachIndexed

            val intent = Intent(this, AdhanAlarmReceiver::class.java).apply {
                putExtra(AdhanAlarmReceiver.EXTRA_PRAYER_NAME, name)
                putExtra(AdhanAlarmReceiver.EXTRA_MUEZZIN_ID, muezzinId)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                this, 9400 + index, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, millis, pendingIntent)
        }
    }
}
