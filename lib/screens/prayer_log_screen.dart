import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';


/// شاشة "سجل الصلاة": تقويم شهري يوضح كل يوم كام صلاة من الخمسة اتصلّت
/// فيه، بالإضافة لملخّص الشهر والسلسلة المتتالية الحالية.
class PrayerLogScreen extends StatefulWidget {
  const PrayerLogScreen({super.key});

  @override
  State<PrayerLogScreen> createState() => _PrayerLogScreenState();
}

class _PrayerLogScreenState extends State<PrayerLogScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  Map<int, int> _summary = {};
  int _streak = 0;
  bool _loading = true;

  static const _weekDays = ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
  static const _monthNames = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final summary = await SettingsService.instance.getMonthlySummary(_month);
    final streak = await SettingsService.instance.getPrayerStreak();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _streak = streak;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
    _load();
  }

  Color _colorFor(int done) {
    final green = AppColors.brand(context);
    switch (done) {
      case 5:
        return green;
      case 4:
        return green.withOpacity(0.7);
      case 3:
        return green.withOpacity(0.5);
      case 2:
        return green.withOpacity(0.32);
      case 1:
        return green.withOpacity(0.18);
      default:
        return AppColors.isDark(context)
            ? Colors.white.withOpacity(0.07)
            : Colors.grey.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = _month.year == now.year && _month.month == now.month;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // 0 = Sunday بما يناسب ترتيب أعمدة الأسبوع العربي فوق
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;

    final fullDays = _summary.values.where((v) => v == 5).length;
    final daysCounted = isCurrentMonth ? now.day : daysInMonth;
    final totalDone = _summary.entries
        .where((e) => e.key <= daysCounted)
        .fold<int>(0, (sum, e) => sum + e.value);
    final commitmentPct =
        daysCounted == 0 ? 0 : ((totalDone / (daysCounted * 5)) * 100).round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('سجل الصلاة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ملخّص علوي: السلسلة الحالية + نسبة الالتزام هذا الشهر
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: '🔥',
                        value: '$_streak',
                        label: 'يوم متتالي',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: '📅',
                        value: '$fullDays',
                        label: 'يوم مكتمل هذا الشهر',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: '📈',
                        value: '$commitmentPct%',
                        label: 'نسبة الالتزام',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // شريط التنقل بين الشهور
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                    Text(
                      '${_monthNames[_month.month - 1]} ${_month.year}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // رؤوس أيام الأسبوع
                Row(
                  children: _weekDays
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d, style: TextStyle(fontSize: 11, color: AppColors.muted(context))),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),

                // شبكة التقويم
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: firstWeekday + daysInMonth,
                  itemBuilder: (context, index) {
                    if (index < firstWeekday) return const SizedBox.shrink();
                    final day = index - firstWeekday + 1;
                    final done = _summary[day] ?? 0;
                    final isToday = isCurrentMonth && day == now.day;
                    return Container(
                      decoration: BoxDecoration(
                        color: _colorFor(done),
                        borderRadius: BorderRadius.circular(8),
                        border: isToday ? Border.all(color: const Color(0xFFD4AF37), width: 2) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: done >= 3
                              ? (AppColors.isDark(context)
                                  ? const Color(0xFF07130D)
                                  : Colors.white)
                              : AppColors.text(context),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // مفتاح الألوان
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [0, 1, 3, 5].map((n) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(color: _colorFor(n), borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          n == 0 ? 'لا صلاة' : n == 5 ? '٥/٥' : '$n/٥',
                          style: TextStyle(fontSize: 11, color: AppColors.muted(context)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brand(context))),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, color: AppColors.muted(context))),
        ],
      ),
    );
  }
}
