import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

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

  /// معرّف المؤذن اللي بيتجرّب صوته دلوقتي (null = مفيش تشغيل).
  /// الشاشات بتسمع له عشان تبدّل أيقونة تشغيل/إيقاف بشكل صحيح.
  final ValueNotifier<String?> playingId = ValueNotifier<String?>(null);

  /// أقصى مدة لتجربة الصوت (الأذان كامل ممكن يعدي دقيقتين).
  static const Duration previewLimit = Duration(seconds: 25);
  Timer? _limitTimer;
  bool _listening = false;

  void _listen() {
    if (_listening) return;
    _listening = true;
    _player.onPlayerComplete.listen((_) => _clear());
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        _clear();
      }
    });
  }

  void _clear() {
    _limitTimer?.cancel();
    playingId.value = null;
  }

  /// قائمة المؤذنين المتاحين. الـ id هو نفسه اسم الملف الصوتي بدون امتداد
  /// (مطابق للقيم المستخدمة في شاشة الإعدادات ومكتبة الأصوات).
  /// المؤذنين اللي عندهم صوت حقيقي فعلاً (مش نغمة placeholder) في الأول.
  static const List<Map<String, String>> availableMuezzins = [
    {'id': 'mishary_alafasy', 'label': 'الشيخ مشاري راشد العفاسي'},
    {'id': 'abdul_basit', 'label': 'الشيخ عبد الباسط عبد الصمد'},
    {'id': 'madinah', 'label': 'أذان المسجد النبوي الشريف'},
    {'id': 'al_aqsa', 'label': 'أذان المسجد الأقصى المبارك'},
  ];

  Future<bool> playAdhan(String muezzinId) async {
    _listen();
    try {
      await _player.stop();
      await _player.setVolume(1.0);
      await _player.play(AssetSource('audio/$muezzinId.mp3'));
      playingId.value = muezzinId;
      _limitTimer?.cancel();
      _limitTimer = Timer(previewLimit, stop);
      return true;
    } catch (_) {
      // الملف غير موجود أو تعذر تشغيله - نرجع false بهدوء
      _clear();
      return false;
    }
  }

  /// زرار التجربة: لو نفس المؤذن شغال يوقفه، وإلا يشغّله.
  /// يرجع false بس لو التشغيل فشل.
  Future<bool> togglePreview(String muezzinId) async {
    if (playingId.value == muezzinId) {
      await stop();
      return true;
    }
    return playAdhan(muezzinId);
  }

  Future<void> stop() async {
    _clear();
    try {
      await _player.stop();
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
