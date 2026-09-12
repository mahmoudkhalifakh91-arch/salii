import 'package:flutter/services.dart';

/// بوابة (platform channel) بين Flutter والكود الأصلي في أندرويد
/// (Accessibility Service + Overlay + Usage Stats) المسؤولة عن قفل
/// التطبيقات المشتتة تلقائياً مع دخول وقت كل صلاة.
///
/// ملحوظة مهمة: الميزة دي مبنية على صلاحيات أندرويد خاصة (Accessibility
/// Service، رسم فوق التطبيقات، الوصول لإحصائيات الاستخدام) ومينفعش
/// تتفحص إلا على جهاز حقيقي — مش هتشتغل في أي محاكي أو بمجرد نجاح البناء.
class AppBlockService {
  AppBlockService._();
  static final AppBlockService instance = AppBlockService._();

  static const MethodChannel _channel = MethodChannel('salli/app_block');

  Future<bool> hasOverlayPermission() async {
    try {
      return (await _channel.invokeMethod<bool>('hasOverlayPermission')) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      return (await _channel
              .invokeMethod<bool>('isAccessibilityServiceEnabled')) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (_) {}
  }

  Future<bool> hasUsageStatsPermission() async {
    try {
      return (await _channel.invokeMethod<bool>('hasUsageStatsPermission')) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
    } catch (_) {}
  }

  /// يحفظ قائمة أسماء حزم التطبيقات (package name) اللي المستخدم
  /// فعّل تقييدها. دول اللي هيتقفلوا لحظة دخول وقت أي صلاة.
  Future<void> setToggledApps(List<String> packageNames) async {
    try {
      await _channel.invokeMethod('setToggledApps', packageNames);
    } catch (_) {}
  }

  Future<List<String>> getToggledApps() async {
    try {
      final result =
          await _channel.invokeMethod<List<dynamic>>('getToggledApps');
      return result?.map((e) => e.toString()).toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  /// التطبيقات المقفولة فعلياً دلوقتي (بعد ما حصل أذان واتقفلت).
  /// دول مش هيرجعوا يشتغلوا إلا لو المستخدم ألغى القفل يدوياً.
  Future<List<String>> getLockedApps() async {
    try {
      final result =
          await _channel.invokeMethod<List<dynamic>>('getLockedApps');
      return result?.map((e) => e.toString()).toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  /// إلغاء القفل عن تطبيق معين يدوياً من شاشة الإعدادات (الطريقة
  /// الوحيدة لإرجاع تطبيق مقفول للعمل من غير ما تستنى الأذان الجاي).
  Future<void> unlockApp(String packageName) async {
    try {
      await _channel.invokeMethod('unlockApp', {'packageName': packageName});
    } catch (_) {}
  }

  /// يجدول Alarm أصلي (native) لحظة كل صلاة، بحيث القفل يشتغل حتى لو
  /// تطبيق صلّي نفسه مقفول أو في الخلفية وقت الأذان.
  Future<void> schedulePrayerBlocks(List<DateTime> prayerTimes) async {
    try {
      await _channel.invokeMethod(
        'schedulePrayerBlocks',
        prayerTimes.map((t) => t.millisecondsSinceEpoch).toList(),
      );
    } catch (_) {}
  }
}
