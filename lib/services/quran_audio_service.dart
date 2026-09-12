import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

/// قارئ واحد من مكتبة القراءات، مع رابط السيرفر الأساسي بتاعه.
/// رابط السورة الكاملة = server + رقم السورة بصيغة 3 أرقام + .mp3
/// (مثال: https://server8.mp3quran.net/afs/002.mp3)
class QuranReciter {
  final String id;
  final String name;
  final String server;
  final String rewayah;

  const QuranReciter({
    required this.id,
    required this.name,
    required this.server,
    required this.rewayah,
  });

  String surahUrl(int surahNumber) =>
      '$server${surahNumber.toString().padLeft(3, '0')}.mp3';
}

/// خدمة جلب قائمة القرّاء وتشغيل سور كاملة أونلاين من مصدر عام مجاني
/// (mp3quran.net — واجهة API رسمية موثّقة ومتاحة للجميع). محتاجة اتصال
/// إنترنت فعلي عند التشغيل، لأن السور كاملة (قد تتجاوز 100 ميجا للسورة
/// الطويلة) مش منطقي نحطها كملفات داخل التطبيق.
class QuranAudioService {
  QuranAudioService._();
  static final QuranAudioService instance = QuranAudioService._();

  static const _recitersUrl =
      'https://www.mp3quran.net/api/v3/reciters?language=ar&rewaya=1';

  final AudioPlayer _player = AudioPlayer();
  List<QuranReciter>? _cachedReciters;

  /// قائمة احتياطية (fallback) بأسماء قرّاء مشهورين لسيرفراتهم المعروفة،
  /// بتُستخدم فقط لو تعذر الاتصال بالـ API (بدون إنترنت مثلاً).
  static const List<QuranReciter> _fallbackReciters = [
    QuranReciter(
      id: 'afs',
      name: 'مشاري راشد العفاسي',
      server: 'https://server8.mp3quran.net/afs/',
      rewayah: 'حفص عن عاصم',
    ),
    QuranReciter(
      id: 'sds',
      name: 'عبد الرحمن السديس',
      server: 'https://server11.mp3quran.net/sds/',
      rewayah: 'حفص عن عاصم',
    ),
    QuranReciter(
      id: 'basit',
      name: 'عبد الباسط عبد الصمد (مرتل)',
      server: 'https://server7.mp3quran.net/basit/',
      rewayah: 'حفص عن عاصم',
    ),
  ];

  Future<List<QuranReciter>> fetchReciters() async {
    if (_cachedReciters != null) return _cachedReciters!;
    try {
      final response = await http
          .get(Uri.parse(_recitersUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return _fallbackReciters;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = (data['reciters'] as List<dynamic>? ?? [])
          .map((r) => r as Map<String, dynamic>)
          .where((r) => (r['moshaf'] as List<dynamic>? ?? []).isNotEmpty)
          .map((r) {
        final moshaf = (r['moshaf'] as List<dynamic>).first as Map<String, dynamic>;
        return QuranReciter(
          id: r['id'].toString(),
          name: r['name'] as String? ?? '',
          server: moshaf['server'] as String? ?? '',
          rewayah: moshaf['name'] as String? ?? '',
        );
      }).where((r) => r.server.isNotEmpty).toList();

      if (list.isEmpty) return _fallbackReciters;
      _cachedReciters = list;
      return list;
    } catch (_) {
      // لا إنترنت أو تعذر الوصول للـ API - نستخدم القائمة الاحتياطية
      return _fallbackReciters;
    }
  }

  Future<bool> playSurah(String server, int surahNumber) async {
    try {
      await _player.stop();
      final url = '$server${surahNumber.toString().padLeft(3, '0')}.mp3';
      await _player.play(UrlSource(url));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      await _player.resume();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  void dispose() {
    _player.dispose();
  }
}
