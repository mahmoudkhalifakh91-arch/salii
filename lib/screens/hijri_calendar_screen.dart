import 'package:flutter/material.dart';
import '../theme/mushaf_theme.dart';
import '../utils/hijri_date.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  static const List<String> _weekDaysAr = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriDate.fromDateTime(_selectedDate);
    final weekDay = _weekDaysAr[_selectedDate.weekday - 1];

    return Scaffold(
      backgroundColor: MushafTheme.paper,
      appBar: AppBar(
        title: const Text('التقويم الهجري', style: MushafTheme.screenTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: MushafTheme.frameDecoration(),
            child: Column(
              children: [
                Text(weekDay, style: MushafTheme.bodyText.copyWith(fontSize: 15, color: MushafTheme.border, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  '${hijri.day} ${hijri.monthName}',
                  style: MushafTheme.cardTitle.copyWith(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                Text('${hijri.year} هـ', style: MushafTheme.cardTitle.copyWith(fontSize: 22)),
                MushafTheme.ornateDivider(),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} م',
                  style: MushafTheme.bodyText.copyWith(fontSize: 14, color: MushafTheme.ink.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month),
            label: const Text('اختر تاريخًا ميلاديًا آخر', style: TextStyle(fontFamily: MushafTheme.textFont)),
            style: ElevatedButton.styleFrom(
              backgroundColor: MushafTheme.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'هذا تاريخ هجري محسوب حسابيًا (تقويم جدولي)، وقد يختلف يوم واحد أحيانًا عن الإعلان الرسمي المعتمد على رؤية الهلال في بعض الدول، خصوصًا في بداية الشهور مثل رمضان وشوال وذي الحجة.',
              style: TextStyle(fontFamily: MushafTheme.textFont, fontSize: 12, color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
