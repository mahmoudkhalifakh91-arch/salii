import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double _fontSize = 22.0;

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
