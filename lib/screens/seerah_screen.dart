import 'package:flutter/material.dart';
import '../data/seerah_data.dart';
import 'story_list_common.dart';

class SeerahScreen extends StatelessWidget {
  const SeerahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoryListScreen(
      appBarTitle: 'الغزوات والسيرة',
      intro: 'أهم أحداث السيرة النبوية والغزوات مرتبة زمنيًا.',
      entries: seerahEvents
          .map((e) => StoryEntry(title: e.title, subtitle: e.year, body: e.summary))
          .toList(),
    );
  }
}
