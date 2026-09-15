/// تحويل التاريخ الميلادي إلى هجري بالحساب الجدولي (Tabular Islamic Calendar).
///
/// ملحوظة مهمة: هذا حساب فلكي/جدولي تقريبي مثل أغلب تقاويم التطبيقات، وقد يختلف
/// يوم واحد أحيانًا عن الإعلان الرسمي المعتمد على رؤية الهلال الفعلية في بعض الدول.
class HijriDate {
  final int year;
  final int month; // 1-12
  final int day;

  const HijriDate({required this.year, required this.month, required this.day});

  static const List<String> monthNames = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  String get monthName => monthNames[month - 1];

  static int _gregorianToJdn(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    final a = (14 - m) ~/ 12;
    final y2 = y + 4800 - a;
    final m2 = m + 12 * a - 3;
    return d +
        ((153 * m2 + 2) ~/ 5) +
        365 * y2 +
        (y2 ~/ 4) -
        (y2 ~/ 100) +
        (y2 ~/ 400) -
        32045;
  }

  factory HijriDate.fromDateTime(DateTime date) {
    const islamicEpoch = 1948440;
    final jdn = _gregorianToJdn(DateTime(date.year, date.month, date.day));
    var l = jdn - islamicEpoch + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = (((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719)) +
        ((l ~/ 5670) * ((43 * l) ~/ 15238));
    l = l -
        (((30 - j) ~/ 15) * ((17719 * j) ~/ 50)) -
        ((j ~/ 16) * ((15238 * j) ~/ 43)) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - ((709 * month) ~/ 24);
    final year = 30 * n + j - 30;
    return HijriDate(year: year, month: month, day: day);
  }

  @override
  String toString() => '$day $monthName $year هـ';
}
