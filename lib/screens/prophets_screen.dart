import 'package:flutter/material.dart';
import '../data/prophets_data.dart';
import '../data/companions_data.dart';
import '../theme/mushaf_theme.dart';
import 'story_list_common.dart';

/// شاشة "قصص الأنبياء والصحابة" بتبويبين: الأنبياء عليهم السلام، والصحابة رضي الله عنهم.
class ProphetsScreen extends StatelessWidget {
  const ProphetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MushafTheme.paper,
        appBar: AppBar(
          title: const Text('قصص الأنبياء والصحابة', style: MushafTheme.screenTitle),
          centerTitle: true,
          bottom: const TabBar(
            labelStyle: TextStyle(fontFamily: MushafTheme.textFont, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'الأنبياء عليهم السلام'),
              Tab(text: 'الصحابة رضي الله عنهم'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _StoryListBody(
              intro: 'الأنبياء الخمسة والعشرون المذكورون بالاسم في القرآن الكريم، بترتيبهم الزمني التقريبي.',
              entries: prophetsStories.map((p) => StoryEntry(title: p.name, body: p.summary)).toList(),
            ),
            _StoryListBody(
              intro: 'نبذات مختصرة عن أبرز الصحابة رضي الله عنهم.',
              entries: companionsStories.map((c) => StoryEntry(title: c.name, body: c.summary)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// جسم قائمة القصص فقط (بدون Scaffold/AppBar خاص بيها) عشان تستخدم جوه تبويب.
class _StoryListBody extends StatelessWidget {
  final String intro;
  final List<StoryEntry> entries;

  const _StoryListBody({required this.intro, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => _StoryDetail(entry: e)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoryDetail extends StatelessWidget {
  final StoryEntry entry;

  const _StoryDetail({required this.entry});

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
