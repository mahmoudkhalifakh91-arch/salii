import 'app_block_service.dart';
import 'notification_service.dart';
import 'prayer_service.dart';

/// نقطة واحدة لجدولة كل تنبيهات الصلاة (إشعار الأذان + شاشة الأذان الأصلية
/// + قفل التطبيقات) لعدة أيام قدّام. كانت الجدولة مكرّرة في 3 شاشات وبتغطي
/// باقي اليوم بس، فالفجر كان ممكن ما يرنّش لو التطبيق ما اتفتحش بعد العشاء.
class PrayerScheduler {
  PrayerScheduler._();

  /// عدد الأيام اللي بنجدولها مقدّمًا (٥ صلوات × ٧ أيام = ٣٥ تنبيه).
  static const int daysAhead = 7;

  static Future<void> rescheduleAll({
    required double latitude,
    required double longitude,
    required String methodKey,
    required String muezzinId,
    required bool notificationsEnabled,
    required bool appBlockEnabled,
  }) async {
    final upcoming = PrayerService.upcomingPrayers(
      latitude: latitude,
      longitude: longitude,
      methodKey: methodKey,
      days: daysAhead,
    );
    final slots = upcoming.map((p) => (name: p.nameAr, time: p.time)).toList();

    if (notificationsEnabled) {
      await NotificationService.instance
          .scheduleForPrayers(upcoming, muezzinId: muezzinId);
      await AppBlockService.instance.scheduleAdhanAlerts(slots, muezzinId);
    } else {
      await NotificationService.instance.cancelAll();
      await AppBlockService.instance.cancelAdhanAlerts();
    }

    if (appBlockEnabled) {
      await AppBlockService.instance.schedulePrayerBlocks(slots);
    } else {
      await AppBlockService.instance.cancelPrayerBlocks();
    }
  }
}
