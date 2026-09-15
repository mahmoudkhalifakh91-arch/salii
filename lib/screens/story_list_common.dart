import 'package:flutter/material.dart';
import '../theme/mushaf_theme.dart';

/// عنصر عرض عام لأي "قصة/حدث" بسيط: عنوان + وصف فرعي اختياري + نص الملخص.
class StoryEntry {
  final String title;
  final String? subtitle;
  final String body;

  const StoryEntry({required this.title, this.subtitle, required this.body});
}

/// شاشة عامة (قائمة + تفاصيل) تُستخدم لعرض أي مجموعة من القصص/الأحداث المبسّطة
/// بنفس تنسيق المصحف (خلفية ورقية، إطار ذهبي، خط Amiri) بدل تكرار نفس الكود
/// في كل شاشة من شاشات المكتبة.
class StoryListScreen extends StatelessWidget {
  final String appBarTitle;
  final String intro;
  final List<StoryEntry> entries;

  const StoryListScreen({
    super.key,
    required this.appBarTitle,
    required this.intro,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MushafTheme.paper,
      appBar: AppBar(
        title: Text(appBarTitle, style: MushafTheme.screenTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: MushafTheme.green.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              intro,
              style: const TextStyle(fontFamily: MushafTheme.textFont, fontSize: 12, color: MushafTheme.green),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final e = entries[index];
                return Container(
                  decoration: MushafTheme.frameDecoration(radius: 10),
                  child: ListTile(
                    title: Text(e.title, style: MushafTheme.cardTitle.copyWith(fontSize: 16)),
                    subtitle: e.subtitle != null
                        ? Text(e.subtitle!, style: MushafTheme.bodyText.copyWith(fontSize: 12, height: 1.2))
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => _StoryDetailScreen(entry: e)),
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

class _StoryDetailScreen extends StatelessWidget {
  final StoryEntry entry;

  const _StoryDetailScreen({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MushafTheme.paper,
      appBar: AppBar(title: Text(entry.title, style: MushafTheme.screenTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: MushafTheme.frameDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(entry.title, style: MushafTheme.cardTitle, textAlign: TextAlign.center),
                if (entry.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.subtitle!,
                    style: MushafTheme.bodyText.copyWith(fontSize: 13, color: MushafTheme.border, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
                MushafTheme.ornateDivider(),
                Text(entry.body, style: MushafTheme.bodyText, textAlign: TextAlign.justify, textDirection: TextDirection.rtl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
