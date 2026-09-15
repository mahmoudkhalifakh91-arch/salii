import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ملحوظة: "كتاب رحلتي مع القرآن" اتفهمت هنا كميزة شخصية داخل التطبيق
/// (متابعة ختمة + دفتر خواطر/تدبر)، مش نص كتاب خارجي بعينه. لو المقصود كان
/// كتاب منشور محدد، تحتاج تقولي عنوانه ومؤلفه عشان محتواه يتراجع بدل ما يتكتب هنا.
class JournalNote {
  final String id;
  final DateTime date;
  final String text;

  JournalNote({required this.id, required this.date, required this.text});

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'text': text,
      };

  factory JournalNote.fromJson(Map<String, dynamic> json) => JournalNote(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        text: json['text'] as String,
      );
}

class QuranJourneyService {
  QuranJourneyService._();
  static final QuranJourneyService instance = QuranJourneyService._();

  static const _keyCompletedJuz = 'quran_journey_completed_juz';
  static const _keyNotes = 'quran_journey_notes';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  /// أرقام الأجزاء (١-٣٠) اللي المستخدم علّم إنه خَتَمها.
  Future<Set<int>> getCompletedJuz() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_keyCompletedJuz) ?? [];
    return list.map(int.parse).toSet();
  }

  Future<void> toggleJuz(int juz) async {
    final prefs = await _prefs;
    final current = await getCompletedJuz();
    if (current.contains(juz)) {
      current.remove(juz);
    } else {
      current.add(juz);
    }
    await prefs.setStringList(_keyCompletedJuz, current.map((e) => e.toString()).toList());
  }

  Future<List<JournalNote>> getNotes() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_keyNotes) ?? [];
    final notes = list.map((s) => JournalNote.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
    notes.sort((a, b) => b.date.compareTo(a.date));
    return notes;
  }

  Future<void> addNote(String text) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_keyNotes) ?? [];
    final note = JournalNote(id: DateTime.now().microsecondsSinceEpoch.toString(), date: DateTime.now(), text: text);
    list.add(jsonEncode(note.toJson()));
    await prefs.setStringList(_keyNotes, list);
  }

  Future<void> deleteNote(String id) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_keyNotes) ?? [];
    list.removeWhere((s) => (jsonDecode(s) as Map<String, dynamic>)['id'] == id);
    await prefs.setStringList(_keyNotes, list);
  }
}
