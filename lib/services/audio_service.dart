import 'package:audioplayers/audioplayers.dart';

/// خدمة تشغيل صوت الأذان. تعتمد على ملفات mp3 موجودة داخل assets/audio/
/// باسم مطابق لمعرّف المؤذن (مثال: assets/audio/makkah.mp3).
///
/// ملاحظة: المشروع لسه من غير ملفات صوت أذان حقيقية — لازم تضيفها بنفسك
/// في assets/audio/ (راجع assets/audio/README.md). لو الملف مش موجود،
/// play() هترجع false بدل ما تعمل crash للتطبيق.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();

  /// قائمة المؤذنين المتاحين. الـ id هو نفسه اسم الملف الصوتي بدون امتداد
  /// (مطابق للقيم المستخدمة في شاشة الإعدادات ومكتبة الأصوات).
  /// المؤذنين اللي عندهم صوت حقيقي فعلاً (مش نغمة placeholder) في الأول.
  static const List<Map<String, String>> availableMuezzins = [
    {'id': 'mishary_alafasy', 'label': 'الشيخ مشاري راشد العفاسي'},
    {'id': 'abdul_basit', 'label': 'الشيخ عبد الباسط عبد الصمد'},
    {'id': 'madinah', 'label': 'أذان المسجد النبوي الشريف'},
    {'id': 'al_aqsa', 'label': 'أذان المسجد الأقصى المبارك'},
    {'id': 'makkah', 'label': 'أذان الحرم المكي الشريف'},
    {'id': 'sudais', 'label': 'الشيخ عبد الرحمن السديس'},
    {'id': 'shuraim', 'label': 'الشيخ سعود الشريم'},
    {'id': 'maher_almuaiqly', 'label': 'الشيخ ماهر المعيقلي'},
    {'id': 'muhammad_thuwaini', 'label': 'الشيخ محمد ثويني'},
    {'id': 'hafez_alsherazy', 'label': 'الشيخ حافظ الشيرازي'},
  ];

  Future<bool> playAdhan(String muezzinId) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/$muezzinId.mp3'));
      return true;
    } catch (_) {
      // الملف غير موجود أو تعذر تشغيله - نرجع false بهدوء
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
