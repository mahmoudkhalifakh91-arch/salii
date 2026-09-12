package com.salli.salli_app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

/**
 * الخدمة دي هي "المحرك" الفعلي لميزة الوقف الذكي. بتفضل شغالة في
 * الخلفية طول ما المستخدم مفعّلها من إعدادات النظام (Accessibility)،
 * وبترصد أي تبديل بين التطبيقات (TYPE_WINDOW_STATE_CHANGED). لو
 * التطبيق اللي فتحه المستخدم موجود في قائمة "المقفولة"، بتفتح شاشة
 * القفل (BlockedAppActivity) فوقه فورًا.
 *
 * ملحوظة: بعض الشركات المصنّعة (شاومي، هواوي، وغيرها) بتوقف الخدمات
 * اللي شغالة في الخلفية بقوة لتوفير البطارية. لو الميزة وقفت تشتغل
 * فجأة، المستخدم غالبًا محتاج يستثني صلّي من تحسين البطارية يدويًا.
 */
class SalliAccessibilityService : AccessibilityService() {

    companion object {
        var instance: SalliAccessibilityService? = null
    }

    private var lastBlockedLaunch = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance === this) instance = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString() ?: return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        if (packageName == applicationContext.packageName) return

        val locked = BlockPrefs.getLockedApps(applicationContext)
        if (locked.contains(packageName)) {
            launchLockScreen()
        }
    }

    /** بتتنفذ لحظة وصول تنبيه الأذان من PrayerBlockReceiver مباشرة. */
    fun blockCurrentForegroundAppIfNeeded() {
        launchLockScreen()
    }

    private fun launchLockScreen() {
        // نتجنب فتح الشاشة أكتر من مرة في وقت قصير جدًا (تكرار أحداث accessibility)
        val now = System.currentTimeMillis()
        if (now - lastBlockedLaunch < 800) return
        lastBlockedLaunch = now

        val intent = Intent(this, BlockedAppActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
        }
        startActivity(intent)
    }

    override fun onInterrupt() {}
}
