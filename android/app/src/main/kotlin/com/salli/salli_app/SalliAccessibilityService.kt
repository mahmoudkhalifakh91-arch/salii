package com.salli.salli_app

import android.accessibilityservice.AccessibilityService
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.widget.TextView

/**
 * الخدمة دي هي "المحرك" الفعلي لميزة الوقف الذكي. بتفضل شغالة في
 * الخلفية طول ما المستخدم مفعّلها من إعدادات النظام (Accessibility)،
 * وبترصد أي تبديل بين التطبيقات (TYPE_WINDOW_STATE_CHANGED). لو
 * التطبيق اللي فتحه المستخدم موجود في قائمة "المقفولة"، بترجعه فورًا
 * للشاشة الرئيسية وتعرض رسالة تنبيه بسيطة فوق الشاشة.
 *
 * ملحوظة: بعض الشركات المصنّعة (شاومي، هواوي، وغيرها) بتوقف الخدمات
 * اللي شغالة في الخلفية بقوة لتوفير البطارية. لو الميزة وقفت تشتغل
 * فجأة، المستخدم غالبًا محتاج يستثني صلّي من تحسين البطارية يدويًا.
 */
class SalliAccessibilityService : AccessibilityService() {

    companion object {
        var instance: SalliAccessibilityService? = null
    }

    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance === this) instance = null
        removeOverlay()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val packageName = event?.packageName?.toString() ?: return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        if (packageName == applicationContext.packageName) return

        val locked = BlockPrefs.getLockedApps(applicationContext)
        if (locked.contains(packageName)) {
            blockCurrentApp()
        }
    }

    /** بتتنفذ لحظة وصول تنبيه الأذان من PrayerBlockReceiver مباشرة. */
    fun forceHomeIfCurrentAppBlocked() {
        blockCurrentApp()
    }

    private fun blockCurrentApp() {
        performGlobalAction(GLOBAL_ACTION_HOME)
        showOverlay()
    }

    override fun onInterrupt() {}

    private fun showOverlay() {
        if (overlayView != null) return
        try {
            val wm = getSystemService(WINDOW_SERVICE) as WindowManager
            val text = TextView(this).apply {
                text = "🕌 حان وقت الصلاة\nالتطبيق مقفول الآن، تقدر تلغي القفل من إعدادات صلّي"
                textSize = 15f
                setTextColor(0xFFFFFFFF.toInt())
                setBackgroundColor(0xE60F5132.toInt())
                setPadding(56, 40, 56, 40)
                gravity = Gravity.CENTER
            }
            val overlayType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
            }
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                overlayType,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT
            )
            params.gravity = Gravity.CENTER
            wm.addView(text, params)
            overlayView = text
            handler.postDelayed({ removeOverlay() }, 3500)
        } catch (_: Exception) {
            // لو صلاحية الرسم فوق التطبيقات مش متاحة، نكتفي بإرجاع المستخدم
            // للرئيسية من غير ما نعرض رسالة (بدل ما نعمل crash)
        }
    }

    private fun removeOverlay() {
        val view = overlayView ?: return
        try {
            val wm = getSystemService(WINDOW_SERVICE) as WindowManager
            wm.removeView(view)
        } catch (_: Exception) {
        }
        overlayView = null
    }
}
