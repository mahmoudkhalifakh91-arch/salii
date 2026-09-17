package com.salli.salli_app

import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.SeekBar
import android.widget.TextView

/**
 * الشاشة اللي بتظهر بالظبط لحظة دخول وقت كل صلاة، وبتشغل صوت الأذان
 * الحقيقي تلقائيًا (من res/raw/<معرّف المؤذن>.mp3) مش مجرد نغمة إشعار
 * قصيرة. فيها زرار تشغيل/إيقاف، إغلاق، تذكير لاحقاً (10 دقايق)، وشريط صوت.
 */
class AdhanAlertActivity : Activity() {

    private var mediaPlayer: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private var isPlaying = false

    private lateinit var prayerName: String
    private lateinit var muezzinId: String

    // حد أقصى أمان لمدة عرض الشاشة حتى لو الصوت لسبب ما فضل شغال
    // (أذان طويل جدًا أو ملف تالف) — تتقفل تلقائيًا بعد 4 دقايق.
    private val maxDurationMs = 4 * 60 * 1000L

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )
        setContentView(R.layout.activity_adhan_alert)

        // نرفع صوت جهاز الإنذار (Alarm) في النظام لأقصى درجة، عشان الأذان
        // يتسمع فعلاً حتى لو المستخدم كان مخلي صوت الجهاز واطي أو متوسط.
        // شريط التحكم في الشاشة بيفضل شغال بعد كده لو حب يخفّضه بنفسه.
        raiseAlarmStreamVolumeToMax()

        prayerName = intent.getStringExtra(AdhanAlarmReceiver.EXTRA_PRAYER_NAME) ?: "الصلاة"
        muezzinId = intent.getStringExtra(AdhanAlarmReceiver.EXTRA_MUEZZIN_ID) ?: "abdul_basit"

        findViewById<TextView>(R.id.prayerNameText).text = "صلاة $prayerName"

        // نلغي الإشعار عشان مايفضلش قاعد في شريط الإشعارات بعد ما فتحنا الشاشة
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).cancel(9600)

        findViewById<FrameLayout>(R.id.closeButton).setOnClickListener { finish() }
        findViewById<FrameLayout>(R.id.playPauseButton).setOnClickListener { togglePlayPause() }
        findViewById<FrameLayout>(R.id.snoozeButton).setOnClickListener { snooze() }

        findViewById<SeekBar>(R.id.volumeSeekBar).setOnSeekBarChangeListener(
            object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                    val volume = progress / 100f
                    mediaPlayer?.setVolume(volume, volume)
                }
                override fun onStartTrackingTouch(seekBar: SeekBar?) {}
                override fun onStopTrackingTouch(seekBar: SeekBar?) {}
            }
        )

        // الأذان يشتغل تلقائيًا فور ظهور الشاشة
        playAdhan(muezzinId)
        handler.postDelayed({ finish() }, maxDurationMs)
    }

    private fun raiseAlarmStreamVolumeToMax() {
        try {
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            // نخليه على أقصى درجة مباشرة (من غير ما نظهر واجهة تغيير الصوت
            // الخاصة بالنظام) عشان الأذان يوصل صوته بوضوح.
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxVolume, 0)
        } catch (_: Exception) {
            // لو تعذّر لأي سبب (جهاز نادر بيمنعها)، الأذان برضه هيشتغل
            // بأقصى مكسب صوتي ممكن من جهته هو (راجع playAdhan).
        }
    }

    private fun playAdhan(muezzinId: String) {
        try {
            val resId = resources.getIdentifier(muezzinId, "raw", packageName)
            if (resId == 0) return // مفيش ملف صوت بهذا الاسم — الشاشة تفضل تظهر من غير صوت

            mediaPlayer = MediaPlayer().apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                }
                val afd = resources.openRawResourceFd(resId)
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                afd.close()
                isLooping = false
                // نبدأ بأقصى مكسب صوتي ممكن من المشغّل نفسه (فوق رفع صوت
                // النظام)، وشريط التحكم في الشاشة يفضل متاح لو حب يخفّضه.
                setVolume(1f, 1f)
                setOnCompletionListener {
                    this@AdhanAlertActivity.isPlaying = false
                    updatePlayPauseUi()
                }
                prepare()
                start()
            }
            isPlaying = true
            updatePlayPauseUi()
        } catch (_: Exception) {
            // تعذر تشغيل الصوت — نسيب الشاشة تظهر برضه من غير صوت بدل ما نعمل crash
        }
    }

    private fun togglePlayPause() {
        val player = mediaPlayer ?: run {
            // لو الصوت وقف/اتقفل خالص، نجرب نشغله تاني من الأول
            playAdhan(muezzinId)
            return
        }
        try {
            if (isPlaying) {
                player.pause()
            } else {
                player.start()
            }
            isPlaying = !isPlaying
            updatePlayPauseUi()
        } catch (_: Exception) {
        }
    }

    private fun updatePlayPauseUi() {
        findViewById<TextView>(R.id.playPauseIcon).text = if (isPlaying) "⏸" else "🔊"
        findViewById<TextView>(R.id.playPauseLabel).text =
            if (isPlaying) "إيقاف الأذان" else "تشغيل الأذان"
    }

    /** يقفل الشاشة دلوقتي، ويعرضها تاني (بنفس الصلاة والمؤذن) بعد 10 دقايق. */
    private fun snooze() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val canScheduleExact =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()
        if (canScheduleExact) {
            val intent = Intent(this, AdhanAlarmReceiver::class.java).apply {
                putExtra(AdhanAlarmReceiver.EXTRA_PRAYER_NAME, prayerName)
                putExtra(AdhanAlarmReceiver.EXTRA_MUEZZIN_ID, muezzinId)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                this, 9700, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val triggerAt = System.currentTimeMillis() + 10 * 60 * 1000L
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        }
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
        } catch (_: Exception) {
        }
        mediaPlayer = null
    }
}
