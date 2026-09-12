import 'package:flutter_test/flutter_test.dart';
import 'package:salli_app/services/prayer_service.dart';

void main() {
  group('PrayerService.calculateTodayPrayers', () {
    test('returns all 6 prayer entries in the correct order', () {
      final prayers = PrayerService.calculateTodayPrayers(
        forDate: DateTime(2030, 6, 15),
      );

      expect(prayers.length, 6);
      expect(prayers.map((p) => p.id).toList(), [
        'fajr',
        'sunrise',
        'dhuhr',
        'asr',
        'maghrib',
        'isha',
      ]);
    });

    test('prayer times are in strictly increasing order through the day',
        () {
      final prayers = PrayerService.calculateTodayPrayers(
        forDate: DateTime(2030, 6, 15),
      );

      for (var i = 1; i < prayers.length; i++) {
        expect(
          prayers[i].time.isAfter(prayers[i - 1].time),
          isTrue,
          reason: '${prayers[i].id} should be after ${prayers[i - 1].id}',
        );
      }
    });

    test('exactly one prayer (or none, if all have passed) is marked as next',
        () {
      final prayers = PrayerService.calculateTodayPrayers(
        forDate: DateTime(2030, 6, 15),
      );

      final nextCount = prayers.where((p) => p.isNext).length;
      expect(nextCount, anyOf(0, 1));
    });
  });
}
