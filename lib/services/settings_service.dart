import 'package:shared_preferences/shared_preferences.dart';

/// خدمة حفظ واسترجاع إعدادات المستخدم محلياً على الجهاز
/// (طريقة حساب المواقيت، المؤذن المختار، تفعيل الإشعارات، استخدام GPS، آخر موقع معروف)
class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _keyCalcMethod = 'calc_method';
  static const _keyMuezzin = 'muezzin';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyUseGps = 'use_gps';
  static const _keyLastLat = 'last_lat';
  static const _keyLastLng = 'last_lng';
  static const _keyLastCity = 'last_city';
  static const _keyDarkMode = 'dark_mode';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // ---- طريقة حساب المواقيت (مطابقة للمفاتيح المستخدمة في PrayerService) ----
  Future<String> getCalcMethod() async {
    final prefs = await _prefs;
    return prefs.getString(_keyCalcMethod) ?? 'egypt';
  }

  Future<void> setCalcMethod(String method) async {
    final prefs = await _prefs;
    await prefs.setString(_keyCalcMethod, method);
  }

  // ---- المؤذن المختار (اسم الملف الصوتي بدون امتداد داخل assets/audio) ----
  Future<String> getMuezzin() async {
    final prefs = await _prefs;
    return prefs.getString(_keyMuezzin) ?? 'abdul_basit';
  }

  Future<void> setMuezzin(String muezzin) async {
    final prefs = await _prefs;
    await prefs.setString(_keyMuezzin, muezzin);
  }

  // ---- الوضع الليلي (Dark Mode) ----
  Future<bool> getDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyDarkMode, enabled);
  }

  // ---- تفعيل / تعطيل إشعارات الأذان ----
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  // ---- استخدام GPS لتحديد الموقع تلقائياً ----
  Future<bool> getUseGps() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyUseGps) ?? true;
  }

  Future<void> setUseGps(bool useGps) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyUseGps, useGps);
  }

  // ---- آخر موقع جغرافي معروف (يُستخدم كنسخة احتياطية عند تعذر GPS) ----
  Future<void> saveLastLocation(
      double lat, double lng, String cityName) async {
    final prefs = await _prefs;
    await prefs.setDouble(_keyLastLat, lat);
    await prefs.setDouble(_keyLastLng, lng);
    await prefs.setString(_keyLastCity, cityName);
  }

  Future<Map<String, dynamic>?> getLastLocation() async {
    final prefs = await _prefs;
    final lat = prefs.getDouble(_keyLastLat);
    final lng = prefs.getDouble(_keyLastLng);
    if (lat == null || lng == null) return null;
    return {
      'lat': lat,
      'lng': lng,
      'city': prefs.getString(_keyLastCity) ?? '',
    };
  }

  // ---- عدّادات الأذكار اليومية (تُحفظ بمفتاح يحوي تاريخ اليوم فتُصفَّر تلقائياً كل يوم) ----
  String _todayKey(String prefix) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return '${prefix}_$dateStr';
  }

  Future<int> getAzkarCount(String zikrId, {required bool isMorning}) async {
    final prefs = await _prefs;
    final key = _todayKey(isMorning ? 'azkar_morning' : 'azkar_evening');
    return prefs.getInt('$key:$zikrId') ?? 0;
  }

  Future<void> setAzkarCount(String zikrId, int count,
      {required bool isMorning}) async {
    final prefs = await _prefs;
    final key = _todayKey(isMorning ? 'azkar_morning' : 'azkar_evening');
    await prefs.setInt('$key:$zikrId', count);
  }

  // ---- تفعيل / تعطيل ميزة "الوقف الذكي" (قفل التطبيقات المشتتة وقت الصلاة) ----
  Future<bool> getAppBlockEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool('app_block_enabled') ?? false;
  }

  Future<void> setAppBlockEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool('app_block_enabled', enabled);
  }

  // ---- القارئ الافتراضي لتشغيل السور كاملة في شاشة المصحف ----
  Future<void> setQuranReciter(String id, String name, String server) async {
    final prefs = await _prefs;
    await prefs.setString('quran_reciter_id', id);
    await prefs.setString('quran_reciter_name', name);
    await prefs.setString('quran_reciter_server', server);
  }

  Future<Map<String, String>?> getQuranReciter() async {
    final prefs = await _prefs;
    final server = prefs.getString('quran_reciter_server');
    if (server == null) return null;
    return {
      'id': prefs.getString('quran_reciter_id') ?? '',
      'name': prefs.getString('quran_reciter_name') ?? '',
      'server': server,
    };
  }

  // ---- عداد المسبحة الإجمالي (تراكمي، لا يتصفر) ----
  Future<int> getTasbeehTotal() async {
    final prefs = await _prefs;
    return prefs.getInt('tasbeeh_total') ?? 0;
  }

  Future<void> setTasbeehTotal(int total) async {
    final prefs = await _prefs;
    await prefs.setInt('tasbeeh_total', total);
  }

  // ---- هل خلّص المستخدم شاشات الترحيب (Onboarding) أول مرة يفتح التطبيق ----
  Future<bool> getOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool('onboarding_complete') ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await _prefs;
    await prefs.setBool('onboarding_complete', complete);
  }

  // ---- عدد الدقايق قبل الأذان اللي يوصل فيها تذكير مسبق ----
  Future<int> getReminderMinutesBeforeAdhan() async {
    final prefs = await _prefs;
    return prefs.getInt('reminder_minutes_before_adhan') ?? 10;
  }

  Future<void> setReminderMinutesBeforeAdhan(int minutes) async {
    final prefs = await _prefs;
    await prefs.setInt('reminder_minutes_before_adhan', minutes);
  }

  // ---- سجل الصلوات المؤدّاة: مجموعة نصوص بصيغة "yyyy-MM-dd|prayerId" ----
  static const _keyPrayerLog = 'prayer_log';
  static const dailyPrayerIds = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Set<String>> _getPrayerLogRaw() async {
    final prefs = await _prefs;
    return (prefs.getStringList(_keyPrayerLog) ?? const []).toSet();
  }

  Future<void> _setPrayerLogRaw(Set<String> entries) async {
    final prefs = await _prefs;
    await prefs.setStringList(_keyPrayerLog, entries.toList());
  }

  Future<bool> isPrayerDone(DateTime date, String prayerId) async {
    final log = await _getPrayerLogRaw();
    return log.contains('${_dateKey(date)}|$prayerId');
  }

  Future<void> setPrayerDone(DateTime date, String prayerId, bool done) async {
    final log = await _getPrayerLogRaw();
    final key = '${_dateKey(date)}|$prayerId';
    if (done) {
      log.add(key);
    } else {
      log.remove(key);
    }
    await _setPrayerLogRaw(log);
  }

  /// كل الصلوات المؤدّاة في يوم معيّن (كمجموعة أرقام الصلوات: fajr, dhuhr...)
  Future<Set<String>> getDonePrayersForDate(DateTime date) async {
    final log = await _getPrayerLogRaw();
    final prefix = '${_dateKey(date)}|';
    return log.where((e) => e.startsWith(prefix)).map((e) => e.split('|')[1]).toSet();
  }

  /// عدد الأيام المتتالية (بما فيها اليوم أو آخر يوم فيه تسجيل) اللي
  /// اكتملت فيها الصلوات الخمسة كاملة، بالرجوع للخلف من النهارده.
  Future<int> getPrayerStreak() async {
    var streak = 0;
    var day = DateTime.now();
    // لو النهارده لسه لم تكتمل صلواته الخمس (طبيعي قبل العشاء)، نبدأ العدّ
    // من إمبارح عشان يوم النهارده الجاري ميقطعش السلسلة قبل ما يخلص.
    final today = await getDonePrayersForDate(day);
    if (today.length < dailyPrayerIds.length) {
      day = day.subtract(const Duration(days: 1));
    }
    while (true) {
      final done = await getDonePrayersForDate(day);
      if (done.length < dailyPrayerIds.length) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
      if (streak > 3650) break; // حماية من حلقة لا نهائية نظريًا فقط
    }
    return streak;
  }
}
