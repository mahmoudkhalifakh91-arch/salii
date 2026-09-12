import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:audioplayers/audioplayers.dart';
import '../services/quran_audio_service.dart';
import '../services/settings_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double _fontSize = 22.0;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  String? _reciterName;

  @override
  void initState() {
    super.initState();
    _loadReciter();
    QuranAudioService.instance.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (state == PlayerState.playing) _isLoadingAudio = false;
      });
    });
  }

  Future<void> _loadReciter() async {
    final saved = await SettingsService.instance.getQuranReciter();
    if (mounted) setState(() => _reciterName = saved?['name']);
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await QuranAudioService.instance.pause();
      return;
    }
    final saved = await SettingsService.instance.getQuranReciter();
    // لو المستخدم لسه مختارش قارئ من مكتبة القراءات، نستخدم قارئ افتراضي معروف
    final server = saved?['server'] ?? 'https://server8.mp3quran.net/afs/';
    setState(() => _isLoadingAudio = true);
    final ok = await QuranAudioService.instance
        .playSurah(server, widget.surahNumber);
    if (!ok && mounted) {
      setState(() => _isLoadingAudio = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تشغيل الصوت، تأكد من اتصال الإنترنت')),
      );
    }
  }

  @override
  void dispose() {
    QuranAudioService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahNum = widget.surahNumber;
    final verseCount = quran.getVerseCount(surahNum);
    final surahName = quran.getSurahNameArabic(surahNum);
    final place = quran.getPlaceOfRevelation(surahNum) == 'Makkah' ? 'مكية' : 'مدنية';

    return Scaffold(
      appBar: AppBar(
        title: Text(surahName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoadingAudio
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
            tooltip: _reciterName != null
                ? 'تشغيل بصوت $_reciterName'
                : 'تشغيل السورة (اختر قارئ من مكتبة القراءات)',
            onPressed: _togglePlay,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'تكبير الخط',
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(16.0, 36.0)),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'تصغير الخط',
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(16.0, 36.0)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Surah Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F5132).withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0F5132).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('سورة $place', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$verseCount آية', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('ترتيبها: $surahNum', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Basmalah (for all except At-Tawbah)
          if (surahNum != 9)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F5132),
                ),
              ),
            ),

          // Verses
          ...List.generate(verseCount, (index) {
            final verseNum = index + 1;
            final verseText = quran.getVerse(surahNum, verseNum, verseEndSymbol: true);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                verseText,
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 2.2,
                  color: Colors.black87,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
