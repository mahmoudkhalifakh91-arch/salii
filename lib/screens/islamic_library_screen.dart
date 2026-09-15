import 'package:flutter/material.dart';
import '../theme/mushaf_theme.dart';
import 'arbaeen_screen.dart';
import 'hijri_calendar_screen.dart';
import 'hisn_almuslim_screen.dart';
import 'prophets_screen.dart';
import 'quran_journey_screen.dart';
import 'quran_stories_screen.dart';
import 'seerah_screen.dart';

class _LibraryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;

  const _LibraryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}

class IslamicLibraryScreen extends StatelessWidget {
  const IslamicLibraryScreen({super.key});

  static final List<_LibraryItem> _items = [
    _LibraryItem(
      title: 'رحلتي مع القرآن',
      subtitle: 'متابعة ختم الأجزاء وتدوين الخواطر والتدبر',
      icon: Icons.menu_book,
      builder: (_) => const QuranJourneyScreen(),
    ),
    _LibraryItem(
      title: 'قصص من القرآن',
      subtitle: 'قصص وردت في القرآن الكريم غير قصص الأنبياء',
      icon: Icons.auto_stories,
      builder: (_) => const QuranStoriesScreen(),
    ),
    _LibraryItem(
      title: 'قصص الأنبياء والصحابة',
      subtitle: 'الأنبياء الخمسة والعشرون وأبرز الصحابة رضي الله عنهم',
      icon: Icons.people_alt,
      builder: (_) => const ProphetsScreen(),
    ),
    _LibraryItem(
      title: 'الغزوات والسيرة',
      subtitle: 'أهم أحداث السيرة النبوية والغزوات مرتبة زمنيًا',
      icon: Icons.shield_moon,
      builder: (_) => const SeerahScreen(),
    ),
    _LibraryItem(
      title: 'الأربعون النووية',
      subtitle: 'الأحاديث الأربعون التي جمعها الإمام النووي رحمه الله',
      icon: Icons.format_quote,
      builder: (_) => const ArbaeenScreen(),
    ),
    _LibraryItem(
      title: 'حصن المسلم',
      subtitle: 'أدعية وأذكار لمواقف الحياة اليومية المختلفة',
      icon: Icons.security,
      builder: (_) => const HisnAlMuslimScreen(),
    ),
    _LibraryItem(
      title: 'التقويم الهجري',
      subtitle: 'تحويل التاريخ الميلادي إلى هجري',
      icon: Icons.calendar_month,
      builder: (_) => const HijriCalendarScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MushafTheme.paper,
      appBar: AppBar(
        title: const Text('المكتبة الإسلامية', style: MushafTheme.screenTitle),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            decoration: MushafTheme.frameDecoration(radius: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: MushafTheme.green.withOpacity(0.12),
                child: Icon(item.icon, color: MushafTheme.green),
              ),
              title: Text(item.title, style: MushafTheme.cardTitle.copyWith(fontSize: 17)),
              subtitle: Text(
                item.subtitle,
                style: MushafTheme.bodyText.copyWith(fontSize: 12, height: 1.3, color: MushafTheme.ink.withOpacity(0.7)),
              ),
              trailing: const Icon(Icons.chevron_left, color: MushafTheme.border),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: item.builder)),
            ),
          );
        },
      ),
    );
  }
}
