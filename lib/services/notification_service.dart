import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_model.dart';

/// خدمة جدولة إشعار عند دخول كل وقت صلاة.
/// تُستدعى مرة عند بدء التطبيق (initialize) ثم تُستدعى scheduleForPrayers
/// كل مرة تتغير فيها مواقيت اليوم أو إعدادات الإشعارات.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelDescription = 'إشعار عند دخول وقت كل صلاة';

  // Android notification channels are immutable once created (بما فيهم الصوت)،
  // فبنعمل channel منفصل لكل مؤذن عشان تغيير المؤذن من الإعدادات يغيّر الصوت فعلاً.
  // لازم اسم الملف في android/app/src/main/res/raw/<muezzinId>.mp3 (بدون امتداد في الكود).
  String _channelIdFor(String muezzinId) => 'prayer_times_channel_$muezzinId';
  String _channelNameFor(String muezzinId) => 'مواقيت الصلاة - $muezzinId';

  Future<void> initialize() async {
    if (_initialized) return;

    // تهيئة قاعدة بيانات المناطق الزمنية وتحديد التوقيت المحلي للجهاز
    tz_data.initializeTimeZones();
    try {
      final localTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (_) {
      // إن تعذر تحديد المنطقة الزمنية، نبقى على UTC كخيار احتياطي
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  /// يجدول إشعاراً لكل صلاة من مواقيت اليوم (باستثناء الشروق) التي لم يفت وقتها بعد.
  /// يمسح كل الإشعارات القديمة أولاً حتى لا تتكرر أو تبقى مجدولة بمواقيت يوم سابق.
  Future<void> scheduleForPrayers(
    List<PrayerInfo> prayers, {
    String? muezzinId,
  }) async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();

    NotificationDetails notificationDetails;
    if (muezzinId != null) {
      // نحاول نستخدم صوت الأذان المخصص (res/raw/<muezzinId>.mp3). لو الملف
      // مش موجود، ماكس/الأندرويد هيرجع لصوت النظام الافتراضي من غير ما يعمل crash.
      try {
        final androidDetails = AndroidNotificationDetails(
          _channelIdFor(muezzinId),
          _channelNameFor(muezzinId),
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          sound: RawResourceAndroidNotificationSound(muezzinId),
          playSound: true,
        );
        notificationDetails = NotificationDetails(android: androidDetails);
      } catch (_) {
        notificationDetails = _defaultNotificationDetails();
      }
    } else {
      notificationDetails = _defaultNotificationDetails();
    }

    final now = tz.TZDateTime.now(tz.local);
    var id = 0;

    for (final prayer in prayers) {
      // الشروق مش وقت صلاة، منجدلوش إشعار ليه
      if (prayer.id == 'sunrise') continue;

      final scheduled = tz.TZDateTime(
        tz.local,
        prayer.time.year,
        prayer.time.month,
        prayer.time.day,
        prayer.time.hour,
        prayer.time.minute,
      );

      // نتخطى أي وقت فات بالفعل اليوم
      if (scheduled.isBefore(now)) continue;

      await _plugin.zonedSchedule(
        id++,
        'حان الآن وقت صلاة ${prayer.nameAr}',
        'حي على الصلاة، حي على الفلاح',
        scheduled,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }
  }

  NotificationDetails _defaultNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel_default',
      'مواقيت الصلاة',
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
    );
    return const NotificationDetails(android: androidDetails);
  }

  Future<void> cancelAll() async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();
  }
}
