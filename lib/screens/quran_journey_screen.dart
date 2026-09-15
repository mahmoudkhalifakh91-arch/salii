import 'package:flutter/material.dart';
import '../services/quran_journey_service.dart';
import '../theme/mushaf_theme.dart';

/// "كتاب رحلتي مع القرآن": متابعة شخصية لختم الأجزاء الثلاثين + دفتر خواطر وتدبر.
/// ملحوظة: لو كان المقصود كتابًا منشورًا بعينه بدل هذه الميزة الشخصية، محتاج تقولي
/// عنوانه ومؤلفه عشان أراجع محتواه بدل ما يُكتب من الذاكرة.
class QuranJourneyScreen extends StatefulWidget {
  const QuranJourneyScreen({super.key});

  @override
  State<QuranJourneyScreen> createState() => _QuranJourneyScreenState();
}

class _QuranJourneyScreenState extends State<QuranJourneyScreen> {
  Set<int> _completedJuz = {};
  List<JournalNote> _notes = [];
  bool _loading = true;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final juz = await QuranJourneyService.instance.getCompletedJuz();
    final notes = await QuranJourneyService.instance.getNotes();
    if (!mounted) return;
    setState(() {
      _completedJuz = juz;
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _toggleJuz(int juz) async {
    await QuranJourneyService.instance.toggleJuz(juz);
    await _load();
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    await QuranJourneyService.instance.addNote(text);
    _noteController.clear();
    FocusScope.of(context).unfocus();
    await _load();
  }

  Future<void> _deleteNote(String id) async {
    await QuranJourneyService.instance.deleteNote(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MushafTheme.paper,
        appBar: AppBar(
          title: const Text('رحلتي مع القرآن', style: MushafTheme.screenTitle),
          centerTitle: true,
          bottom: const TabBar(
            labelStyle: TextStyle(fontFamily: MushafTheme.textFont, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'متابعة الختمة'),
              Tab(text: 'خواطر وتدبر'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildJuzTracker(),
                  _buildNotes(),
                ],
              ),
      ),
    );
  }

  Widget _buildJuzTracker() {
    final done = _completedJuz.length;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: MushafTheme.green.withOpacity(0.08),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'أنهيت $done من 30 جزءًا. اضغط على أي جزء لتعليمه كمقروء أو إلغاء ذلك.',
            style: const TextStyle(fontFamily: MushafTheme.textFont, fontSize: 12, color: MushafTheme.green),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final juz = index + 1;
              final isDone = _completedJuz.contains(juz);
              return InkWell(
                onTap: () => _toggleJuz(juz),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDone ? MushafTheme.green : MushafTheme.paper,
                    border: Border.all(color: MushafTheme.border, width: 1.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$juz',
                    style: TextStyle(
                      fontFamily: MushafTheme.textFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDone ? Colors.white : MushafTheme.ink,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  minLines: 1,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: MushafTheme.textFont),
                  decoration: InputDecoration(
                    hintText: 'اكتب خاطرة أو تدبّرًا...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: MushafTheme.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addNote,
                icon: const Icon(Icons.send, color: MushafTheme.green),
                tooltip: 'إضافة',
              ),
            ],
          ),
        ),
        Expanded(
          child: _notes.isEmpty
              ? Center(
                  child: Text(
                    'لسه مفيش خواطر مكتوبة.',
                    style: MushafTheme.bodyText.copyWith(color: MushafTheme.ink.withOpacity(0.5)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: _notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Container(
                      decoration: MushafTheme.frameDecoration(radius: 10),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  note.text,
                                  style: MushafTheme.bodyText.copyWith(fontSize: 14),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${note.date.year}/${note.date.month}/${note.date.day}',
                                  style: TextStyle(
                                    fontFamily: MushafTheme.textFont,
                                    fontSize: 11,
                                    color: MushafTheme.ink.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteNote(note.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
