import 'package:flutter/material.dart';
import '../data/arbaeen_data.dart';
import '../theme/mushaf_theme.dart';

class ArbaeenScreen extends StatelessWidget {
  const ArbaeenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MushafTheme.paper,
      appBar: AppBar(
        title: const Text('الأربعون النووية', style: MushafTheme.screenTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: MushafTheme.green.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'الأحاديث الأربعون التي جمعها الإمام النووي رحمه الله. النصوص هنا للمراجعة، ويُنصح دائمًا بمقارنتها بمصدر موثوق.',
              style: TextStyle(fontFamily: MushafTheme.textFont, fontSize: 12, color: MushafTheme.green),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: arbaeenHadiths.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final h = arbaeenHadiths[index];
                return Container(
                  decoration: MushafTheme.frameDecoration(radius: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: MushafTheme.green,
                      child: Text('${h.number}', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(h.title, style: MushafTheme.cardTitle.copyWith(fontSize: 16)),
                    subtitle: Text(h.narrator, style: MushafTheme.bodyText.copyWith(fontSize: 12, height: 1.2)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => _ArbaeenDetailScreen(hadith: h)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArbaeenDetailScreen extends StatelessWidget {
  final ArbaeenHadith hadith;

  const _ArbaeenDetailScreen({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MushafTheme.paper,
      appBar: AppBar(
        title: Text('الحديث ${hadith.number}', style: MushafTheme.screenTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: MushafTheme.frameDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(hadith.title, style: MushafTheme.cardTitle, textAlign: TextAlign.center),
                MushafTheme.ornateDivider(),
                Text(
                  'الراوي: ${hadith.narrator}',
                  style: MushafTheme.bodyText.copyWith(fontSize: 13, color: MushafTheme.ink.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (hadith.text != null)
                  Text(hadith.text!, style: MushafTheme.quranText, textAlign: TextAlign.justify, textDirection: TextDirection.rtl)
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'النص الكامل لهذا الحديث لسه محتاج يُراجع ويُضاف من مصدر موثوق قبل النشر.',
                      style: TextStyle(fontFamily: MushafTheme.textFont, color: Colors.deepOrange),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  hadith.source,
                  style: const TextStyle(fontFamily: MushafTheme.textFont, fontSize: 13, color: MushafTheme.border, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
