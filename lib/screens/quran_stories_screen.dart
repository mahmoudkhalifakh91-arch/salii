import 'package:flutter/material.dart';
import '../data/quran_stories_data.dart';
import 'story_list_common.dart';

class QuranStoriesScreen extends StatelessWidget {
  const QuranStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoryListScreen(
      appBarTitle: 'قصص من القرآن',
      intro: 'قصص وردت في القرآن الكريم غير قصص الأنبياء المفصّلة.',
      entries: quranStories
          .map((s) => StoryEntry(title: s.title, subtitle: s.surahRef, body: s.summary))
          .toList(),
    );
  }
}
