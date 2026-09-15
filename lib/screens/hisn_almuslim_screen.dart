import 'package:flutter/material.dart';
import '../models/azkar_model.dart';
import '../services/azkar_service.dart';
import '../theme/mushaf_theme.dart';

class _HisnCategory {
  final String title;
  final List<ZikrItem> Function() loader;

  const _HisnCategory({required this.title, required this.loader});
}

class HisnAlMuslimScreen extends StatelessWidget {
  const HisnAlMuslimScreen({super.key});

  static final List<_HisnCategory> _categories = [
    _HisnCategory(title: 'دعاء الاستيقاظ من النوم', loader: AzkarService.getWakingUpAzkar),
    _HisnCategory(title: 'دعاء دخول المنزل والخروج منه', loader: AzkarService.getHomeAzkar),
    _HisnCategory(title: 'دعاء دخول المسجد والخروج منه', loader: AzkarService.getMosqueAzkar),
    _HisnCategory(title: 'أدعية الطعام', loader: AzkarService.getEatingAzkar),
    _HisnCategory(title: 'دعاء السفر', loader: AzkarService.getTravelAzkar),
    _HisnCategory(title: 'أذكار بعد الصلاة المكتوبة', loader: AzkarService.getAfterPrayerAzkar),
    _HisnCategory(title: 'دعاء الهمّ والكرب', loader: AzkarService.getDistressAzkar),
    _HisnCategory(title: 'دعاء دخول الخلاء والخروج منه', loader: AzkarService.getBathroomAzkar),
    _HisnCategory(title: 'دعاء لبس الثوب الجديد', loader: AzkarService.getDressingAzkar),
    _HisnCategory(title: 'دعاء العطاس', loader: AzkarService.getSneezeAzkar),
    _HisnCategory(title: 'دعاء الغضب', loader: AzkarService.getAngerAzkar),
    _HisnCategory(title: 'دعاء المطر والرعد', loader: AzkarService.getRainAzkar),
    _HisnCategory(title: 'دعاء عيادة المريض', loader: AzkarService.getSicknessAzkar),
    _HisnCategory(title: 'دعاء قضاء الدَّين وتفريج الهمّ', loader: AzkarService.getReliefAzkar),
    _HisnCategory(title: 'دعاء دخول السوق', loader: AzkarService.getMarketAzkar),
    _HisnCategory(title: 'الدعاء لمن أسدى إليك معروفًا', loader: AzkarService.getThanksReplyAzkar),
    _HisnCategory(title: 'دعاء تهنئة المولود', loader: AzkarService.getNewbornAzkar),
    _HisnCategory(title: 'دعاء التعزية', loader: AzkarService.getCondolenceAzkar),
    _HisnCategory(title: 'دعاء الزواج', loader: AzkarService.getMarriageAzkar),
    _HisnCategory(title: 'دعاء الإفطار', loader: AzkarService.getIftarAzkar),
    _HisnCategory(title: 'دعاء عند هبوب الريح', loader: AzkarService.getWindAzkar),
    _HisnCategory(title: 'دعاء الخوف من الشرك الخفي', loader: AzkarService.getFearOfShirkAzkar),
    _HisnCategory(title: 'الرقية من العين والحسد', loader: AzkarService.getRuqyahAzkar),
    _HisnCategory(title: 'إجابة المؤذن والدعاء بعده', loader: AzkarService.getAdhanResponseAzkar),
    _HisnCategory(title: 'أذكار انتقالات الصلاة', loader: AzkarService.getPrayerMovementsAzkar),
    _HisnCategory(title: 'دعاء صلاة الاستخارة', loader: AzkarService.getIstikharahAzkar),
    _HisnCategory(title: 'دعاء القنوت في الوتر', loader: AzkarService.getQunootAzkar),
    _HisnCategory(title: 'دعاء رؤية الهلال', loader: AzkarService.getNewMoonAzkar),
    _HisnCategory(title: 'تلبية الحج والعمرة', loader: AzkarService.getTalbiyahAzkar),
    _HisnCategory(title: 'دعاء الاستسقاء', loader: AzkarService.getIstisqaAzkar),
    _HisnCategory(title: 'تهنئة العيد', loader: AzkarService.getEidGreetingAzkar),
    _HisnCategory(title: 'دعاء من رأى مبتلى', loader: AzkarService.getSeeingAfflictedAzkar),
    _HisnCategory(title: 'دعاء الفزع والأرق في النوم', loader: AzkarService.getNightFearAzkar),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MushafTheme.paper,
      appBar: AppBar(
        title: const Text('حصن المسلم', style: MushafTheme.screenTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: MushafTheme.green.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Text(
              'أدعية وأذكار لمواقف الحياة اليومية المختلفة. أذكار الصباح والمساء والنوم موجودة في تبويب "الأذكار" الرئيسي.',
              style: TextStyle(fontFamily: MushafTheme.textFont, fontSize: 12, color: MushafTheme.green),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = _categories[index];
                return Container(
                  decoration: MushafTheme.frameDecoration(radius: 10),
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: MushafTheme.green),
                    title: Text(c.title, style: MushafTheme.cardTitle.copyWith(fontSize: 16)),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => _HisnCategoryScreen(title: c.title, items: c.loader())),
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

class _HisnCategoryScreen extends StatelessWidget {
  final String title;
  final List<ZikrItem> items;

  const _HisnCategoryScreen({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MushafTheme.paper,
      appBar: AppBar(title: Text(title, style: MushafTheme.screenTitle), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: MushafTheme.frameDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.textAr, style: MushafTheme.quranText.copyWith(fontSize: 19), textAlign: TextAlign.justify, textDirection: TextDirection.rtl),
                const SizedBox(height: 10),
                Text(
                  item.descriptionAr,
                  style: MushafTheme.bodyText.copyWith(fontSize: 12, color: MushafTheme.ink.withOpacity(0.65)),
                  textAlign: TextAlign.center,
                ),
                if (item.repeat > 1) ...[
                  const SizedBox(height: 6),
                  Text(
                    'التكرار: ${item.repeat} مرات',
                    style: const TextStyle(fontFamily: MushafTheme.textFont, fontSize: 12, color: MushafTheme.border, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
