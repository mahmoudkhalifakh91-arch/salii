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
}
