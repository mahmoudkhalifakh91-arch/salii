import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/azkar_service.dart';
import '../services/settings_service.dart';
import '../models/azkar_model.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<ZikrItem> _morningAzkar;
  late List<ZikrItem> _eveningAzkar;
  late List<ZikrItem> _sleepAzkar;

  // Electronic Tasbeeh counter
  int _tasbeehCount = 0;
  String _currentTasbeehZikr = 'سبحان الله وبحمده';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _morningAzkar = AzkarService.getMorningAzkar();
    _eveningAzkar = AzkarService.getEveningAzkar();
    _sleepAzkar = AzkarService.getSleepAzkar();
    _loadSavedProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// يحمّل عدّادات الأذكار المحفوظة لليوم الحالي (تتصفر تلقائياً كل يوم جديد)
  /// وعداد المسبحة المحفوظ من آخر جلسة.
  Future<void> _loadSavedProgress() async {
    for (final zikr in _morningAzkar) {
      zikr.count = await SettingsService.instance
          .getAzkarCount(zikr.id, isMorning: true);
    }
    for (final zikr in _eveningAzkar) {
      zikr.count = await SettingsService.instance
          .getAzkarCount(zikr.id, isMorning: false);
    }
    final savedTasbeeh = await SettingsService.instance.getTasbeehTotal();
    if (!mounted) return;
    setState(() {
      _tasbeehCount = savedTasbeeh;
    });
  }

  void _incrementZikr(ZikrItem item, {required bool isMorning}) {
    if (!item.isCompleted) {
      HapticFeedback.lightImpact();
      setState(() {
        item.increment();
      });
      SettingsService.instance
          .setAzkarCount(item.id, item.count, isMorning: isMorning);
    }
  }

  void _incrementTasbeeh() {
    HapticFeedback.mediumImpact();
    setState(() {
      _tasbeehCount++;
    });
    SettingsService.instance.setTasbeehTotal(_tasbeehCount);
  }

  void _resetTasbeeh() {
    setState(() {
      _tasbeehCount = 0;
    });
    SettingsService.instance.setTasbeehTotal(0);
  }

  Widget _buildAzkarList(List<ZikrItem> list, {bool? isMorning}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final zikr = list[index];
        final isDone = zikr.isCompleted;

        return GestureDetector(
          onTap: () {
            if (isMorning != null) {
              _incrementZikr(zikr, isMorning: isMorning);
            } else if (!zikr.isCompleted) {
              HapticFeedback.lightImpact();
              setState(() => zikr.increment());
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF0F5132).withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDone
                    ? const Color(0xFF0F5132).withOpacity(0.4)
                    : Colors.grey.withOpacity(0.2),
                width: isDone ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  zikr.textAr,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                    color: isDone ? Colors.grey.shade700 : Colors.black87,
                  ),
                ),
                if (zikr.descriptionAr.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    zikr.descriptionAr,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التكرار: ${zikr.repeat}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF0F5132)
                            : const Color(0xFF0F5132).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDone ? 'اكتمل ✓' : '${zikr.count} / ${zikr.repeat}',
                        style: TextStyle(
                          color: isDone ? Colors.white : const Color(0xFF0F5132),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasbeehView() {
    final phrases = [
      'سبحان الله وبحمده',
      'سبحان الله العظيم',
      'الحمد لله',
      'لا إله إلا الله',
      'الله أكبر',
      'أستغفر الله العظيم وأتوب إليه',
      'اللهم صلِّ وسلم على نبينا محمد',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Select Phrase
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currentTasbeehZikr,
                isExpanded: true,
                items: phrases.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _currentTasbeehZikr = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Big Circular Tasbeeh Button
          GestureDetector(
            onTap: _incrementTasbeeh,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F5132), Color(0xFF1B7A4E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_tasbeehCount',
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'اضغط للتسبيح',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Reset Button
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            label: const Text('إعادة تعيين العداد', style: TextStyle(color: Colors.redAccent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _resetTasbeeh,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار والمسبحة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF0F5132),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0F5132),
          tabs: const [
            Tab(text: 'أذكار الصباح'),
            Tab(text: 'أذكار المساء'),
            Tab(text: 'أذكار النوم'),
            Tab(text: 'المسبحة الإلكترونية'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAzkarList(_morningAzkar, isMorning: true),
          _buildAzkarList(_eveningAzkar, isMorning: false),
          _buildAzkarList(_sleepAzkar),
          _buildTasbeehView(),
        ],
      ),
    );
  }
}
