import 'package:geolocator/geolocator.dart';
import 'settings_service.dart';

/// نتيجة تحديد الموقع: إحداثيات + اسم مدينة تقريبي (إن أمكن) + هل هو موقع حقيقي أم افتراضي
class AppLocation {
  final double latitude;
  final double longitude;
  final String cityLabel;
  final bool isFallback;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.cityLabel,
    this.isFallback = false,
  });
}

/// خدمة تحديد الموقع الجغرافي عبر GPS، مع خطة بديلة:
/// GPS الحالي -> آخر موقع محفوظ -> القاهرة كموقع افتراضي نهائي.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  // إحداثيات القاهرة كموقع افتراضي نهائي إذا تعذر كل شيء آخر
  static const double _cairoLat = 30.0444;
  static const double _cairoLng = 31.2357;

  Future<AppLocation> getCurrentLocation({bool forceRefresh = false}) async {
    final useGps = await SettingsService.instance.getUseGps();

    if (useGps) {
      final position = await _tryGetGpsPosition();
      if (position != null) {
        await SettingsService.instance.saveLastLocation(
          position.latitude,
          position.longitude,
          '',
        );
        return AppLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          cityLabel: 'موقعك الحالي',
        );
      }
    }

    // فشل GPS أو معطل من الإعدادات -> نجرب آخر موقع محفوظ
    final last = await SettingsService.instance.getLastLocation();
    if (last != null) {
      return AppLocation(
        latitude: last['lat'] as double,
        longitude: last['lng'] as double,
        cityLabel: (last['city'] as String).isEmpty
            ? 'آخر موقع محفوظ'
            : last['city'] as String,
        isFallback: true,
      );
    }

    // لا يوجد شيء محفوظ ولا GPS متاح -> القاهرة كافتراضي
    return const AppLocation(
      latitude: _cairoLat,
      longitude: _cairoLng,
      cityLabel: 'القاهرة (افتراضي)',
      isFallback: true,
    );
  }

  /// يحاول الحصول على موقع GPS فعلي، ويتعامل مع كل حالات الأذونات وتعطيل الخدمة.
  /// يرجع null إذا تعذر ذلك لأي سبب (بدل ما يرمي استثناء يوقف التطبيق).
  Future<Position?> _tryGetGpsPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 12));

      return position;
    } catch (_) {
      // أي خطأ (مهلة، خدمة غير متاحة، جهاز بدون GPS...) -> نرجع null
      // ونسمح للتطبيق يكمل بموقع بديل بدل ما يتعطل بالكامل
      return null;
    }
  }
}
