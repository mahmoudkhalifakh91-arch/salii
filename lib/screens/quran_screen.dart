import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'islamic_library_screen.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 114 Surahs
    final surahIndices = List.generate(114, (i) => i + 1);
    final filteredSurahs = surahIndices.where((num) {
      final nameAr = quran.getSurahNameArabic(num);
      final nameEn = quran.getSurahName(num);
      return nameAr.contains(_searchQuery) ||
          nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          num.toString() == _searchQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحف الشريف', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_stories_outlined),
            tooltip: 'المكتبة الإسلامية',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IslamicLibraryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث باسم السورة أو رقمها...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0F5132)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // Surahs List
          Expanded(
            child: ListView.separated(
              itemCount: filteredSurahs.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
              itemBuilder: (context, index) {
                final surahNum = filteredSurahs[index];
                final nameAr = quran.getSurahNameArabic(surahNum);
                final verseCount = quran.getVerseCount(surahNum);
                final isMakki = quran.getPlaceOfRevelation(surahNum) == 'Makkah';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F5132).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$surahNum',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F5132),
                      ),
                    ),
                  ),
                  title: Text(
                    nameAr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${isMakki ? "مكية" : "مدنية"} • $verseCount آيات',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahDetailScreen(surahNumber: surahNum),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
