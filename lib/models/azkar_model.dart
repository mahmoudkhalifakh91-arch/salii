class ZikrItem {
  final String id;
  final String textAr;
  final String textEn;
  final int repeat;
  final String descriptionAr;
  final String descriptionEn;
  int count;

  ZikrItem({
    required this.id,
    required this.textAr,
    required this.textEn,
    required this.repeat,
    required this.descriptionAr,
    required this.descriptionEn,
    this.count = 0,
  });

  bool get isCompleted => count >= repeat;

  void increment() {
    if (count < repeat) {
      count++;
    }
  }

  void reset() {
    count = 0;
  }
}
