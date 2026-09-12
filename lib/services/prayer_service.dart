import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import '../models/prayer_model.dart';

class PrayerService {
  // Default coordinates (Cairo) if GPS is disabled or unavailable
  static const double defaultLat = 30.0444;
  static const double defaultLng = 31.2357;

  /// Calculates prayer times offline using astronomical algorithms
  static List<PrayerInfo> calculateTodayPrayers({
    double latitude = defaultLat,
    double longitude = defaultLng,
    String methodKey = 'egypt',
    DateTime? forDate,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final targetDate = forDate ?? DateTime.now();
    final date = DateComponents.from(targetDate);

    CalculationParameters params;
    switch (methodKey) {
      case 'umm_al_qura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'mwl':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'isna':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'egypt':
      default:
        params = CalculationMethod.egyptian.getParameters();
        break;
    }

    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(coordinates, date, params);
    final now = DateTime.now();

    final prayers = [
      PrayerInfo(id: 'fajr', nameAr: 'الفجر', nameEn: 'Fajr', time: prayerTimes.fajr),
      PrayerInfo(id: 'sunrise', nameAr: 'الشروق', nameEn: 'Sunrise', time: prayerTimes.sunrise),
      PrayerInfo(id: 'dhuhr', nameAr: 'الظهر', nameEn: 'Dhuhr', time: prayerTimes.dhuhr),
      PrayerInfo(id: 'asr', nameAr: 'العصر', nameEn: 'Asr', time: prayerTimes.asr),
      PrayerInfo(id: 'maghrib', nameAr: 'المغرب', nameEn: 'Maghrib', time: prayerTimes.maghrib),
      PrayerInfo(id: 'isha', nameAr: 'العشاء', nameEn: 'Isha', time: prayerTimes.isha),
    ];

    // Determine the next prayer
    String? nextId;
    for (final p in prayers) {
      if (p.time.isAfter(now)) {
        nextId = p.id;
        break;
      }
    }

    return prayers.map((p) {
      return PrayerInfo(
        id: p.id,
        nameAr: p.nameAr,
        nameEn: p.nameEn,
        time: p.time,
        isNext: p.id == nextId,
      );
    }).toList();
  }

  static String formatTime(DateTime time, {String locale = 'ar'}) {
    return DateFormat('h:mm a', locale).format(time);
  }
}
