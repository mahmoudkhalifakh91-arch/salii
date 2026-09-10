class PrayerInfo {
  final String id;
  final String nameAr;
  final String nameEn;
  final DateTime time;
  final bool isNext;

  PrayerInfo({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.time,
    this.isNext = false,
  });
}
