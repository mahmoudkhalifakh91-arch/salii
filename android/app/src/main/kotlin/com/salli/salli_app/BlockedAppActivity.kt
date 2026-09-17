package com.salli.salli_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import android.widget.TextView

/**
 * شاشة القفل اللي بتظهر لما المستخدم يحاول يفتح تطبيق مقفول وقت الصلاة.
 * فيها حالتين:
 *  1) stateLock: العدّاد + زرار "تأكيد أداء الفرض وفتح التطبيقات"
 *  2) stateOath: القسم الشرعي "والله العظيم صليت" + زرار "تم الفرض"
 *
 * الفتح فعلي فقط بعد تأكيد "تم الفرض"، أو تلقائيًا بعد 5 دقايق من
 * الأذان حتى لو المستخدم قفل الشاشة دي أو رجع الهاتف في جيبه
 * (بيتم من خلال PrayerAutoUnlockReceiver المستقل عن هذه الشاشة).
 */
class BlockedAppActivity : Activity() {

    private val handler = Handler(Looper.getMainLooper())
    private var tickRunnable: Runnable? = null

    companion object {
        private const val SESSION_MS = 5 * 60 * 1000L
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // تظهر فوق شاشة القفل نفسها لو الهاتف كان مقفول وقت الأذان
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )
        setContentView(R.layout.activity_blocked_app)

        val prayerName = BlockPrefs.getCurrentPrayerName(applicationContext)
            .ifBlank { "الصلاة" }
        findViewById<TextView>(R.id.prayerNameText).text = prayerName
        findViewById<TextView>(R.id.oathTitle).text = "تأكيد أداء فرض صلاة $prayerName"

        findViewById<TextView>(R.id.confirmPrayerButton).setOnClickListener {
            showOathState()
        }
        findViewById<TextView>(R.id.closeAttemptButton).setOnClickListener {
            goHomeWithoutUnlocking()
        }
        findViewById<TextView>(R.id.oathBackButton).setOnClickListener {
            hideOathState()
        }
        findViewById<TextView>(R.id.oathDoneButton).setOnClickListener {
            BlockPrefs.recordPrayerConfirmed(applicationContext)
            BlockPrefs.endCurrentBlockSession(applicationContext)
            finish()
        }

        startCountdown()
    }

    private fun showOathState() {
        findViewById<android.view.View>(R.id.stateOath).visibility = android.view.View.VISIBLE
    }

    private fun hideOathState() {
        findViewById<android.view.View>(R.id.stateOath).visibility = android.view.View.GONE
    }

    private fun goHomeWithoutUnlocking() {
        // القفل لسه شغال، بس نسيب المستخدم يرجع للرئيسية من غير ما نفتح التطبيق
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }

    private fun startCountdown() {
        val countdownView = findViewById<TextView>(R.id.countdownText)
        tickRunnable = object : Runnable {
            override fun run() {
                val elapsed = System.currentTimeMillis() - BlockPrefs.getAdhanTimestamp(applicationContext)
                val remaining = (SESSION_MS - elapsed).coerceAtLeast(0)

                if (remaining <= 0 || BlockPrefs.getLockedApps(applicationContext).isEmpty()) {
                    // خلصت المهلة أو المستخدم أكّد الصلاة من مكان تاني بالفعل
                    finish()
                    return
                }

                val totalSeconds = (remaining / 1000).toInt()
                val minutes = totalSeconds / 60
                val seconds = totalSeconds % 60
                countdownView.text = String.format("%02d:%02d", minutes, seconds)
                handler.postDelayed(this, 1000)
            }
        }
        handler.post(tickRunnable!!)
    }

    override fun onDestroy() {
        super.onDestroy()
        tickRunnable?.let { handler.removeCallbacks(it) }
    }

    override fun onBackPressed() {
        // منمنع الرجوع للتطبيق المقفول نفسه عن طريق زرار الرجوع
        if (findViewById<android.view.View>(R.id.stateOath).visibility == android.view.View.VISIBLE) {
            hideOathState()
        } else {
            goHomeWithoutUnlocking()
        }
    }
}
