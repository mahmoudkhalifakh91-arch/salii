import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:audioplayers/audioplayers.dart';
import '../services/quran_audio_service.dart';
import '../services/settings_service.dart';

// ألوان صفحة المصحف (ورقي كريمي + بني ذهبي كإطار)
const _kMushafPaper = Color(0xFFFBF3E1);
const _kMushafBorder = Color(0xFFC9A24B);
const _kMushafInk = Color(0xFF1B1B1B);
const _kMushafGreen = Color(0xFF0F5132);

/// يحوّل رقم عادي إلى أرقام هندية (المستخدمة في المصحف)
String _toArabicIndicDigits(int number) {
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number.toString().split('').map((d) => eastern[int.parse(d)]).join();
}

/// علامة نهاية الآية بنفس أسلوب المصحف: رمز "نهاية الآية" ثم رقمها بالهندي،
/// وخط AmiriQuran يرسمها كدائرة زخرفية حول الرقم تلقائياً.
String _ayahEndMarker(int number) => '\u06DD${_toArabicIndicDigits(number)}';

/// يفصّل نص الآية إلى أجزاء ويلوّن كل كلمة تعود على الله عز وجل:
/// لفظ الجلالة "الله" وصيغه الملتصقة بحرف جر/عطف واحد (بالله، فالله، لله، تالله...)
/// بالإضافة إلى كلمة "رب" وصيغها المضافة لضمير (ربي، ربنا، ربك، ربكم، ربه، ربهم...)
/// بنفس أسلوب تلوين "لفظ الجلالة وما يعود عليه" في بعض طبعات المصحف.
///
/// ملحوظة: التلوين هنا مبني على شكل الكلمة نفسها وليس على فهم للمعنى، فمثال نادر
/// زي "رب" لو استُخدمت بمعنى "سيد" بشري (كما في قصة يوسف عليه السلام) هيتلوّن
/// بالخطأ لأن الشكل واحد. الضمائر المنفصلة زي "هو" مقصود عدم تلوينها لأنها تتكرر
/// آلاف المرات في القرآن لمعانٍ مختلفة تمامًا، ومفيش طريقة نصية (مش لغوية/دلالية)
/// تقدر تفرّق بثقة الحالات اللي تعود على الله من غيرها.
const _diacriticsPattern =
    '\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED';
final RegExp _diacriticsRegex = RegExp('[$_diacriticsPattern]');

const List<String> _rabbSuffixes = [
  '', 'نا', 'ك', 'كم', 'كما', 'كن', 'ه', 'ها', 'هم', 'هما', 'هن', 'ي',
];
final Set<String> _rabbForms = _rabbSuffixes.map((s) => 'رب$s').toSet();
const Set<String> _attachablePrefixes = {'و', 'ف', 'ب', 'ل', 'ك'};
const Set<String> _allahExtraPrefixes = {'ت'}; // لصيغة القسم: تالله

String _stripDiacritics(String s) => s.replaceAll(_diacriticsRegex, '');

bool _looksLikeAllah(String bareWord) => bareWord == 'الله' || bareWord == 'لله';

/// يرجع 0 لو الكلمة كلها لفظ جلالة/رب بدون حرف ملتصق، أو 1 لو أول حرف حرف
/// عطف/جر ملتصق والباقي هو لفظ الجلالة أو "رب"، أو null لو مفيش تطابق خالص.
int? _allahOrRabbPrefixLength(String bareWord) {
  if (_looksLikeAllah(bareWord) || _rabbForms.contains(bareWord)) return 0;
  if (bareWord.isEmpty) return null;
  final first = bareWord[0];
  final rest = bareWord.substring(1);
  if ((_attachablePrefixes.contains(first) || _allahExtraPrefixes.contains(first)) &&
      _looksLikeAllah(rest)) {
    return 1;
  }
  if (_attachablePrefixes.contains(first) && _rabbForms.contains(rest)) {
    return 1;
  }
  return null;
}

/// يرجع فهرس الحرف في الكلمة الأصلية (بتشكيلها) اللي بعد أول [baseLetterCount]
/// من الحروف الأساسية (متجاهلين علامات التشكيل)، عشان نعرف نقسم الكلمة لجزء
/// (الحرف الملتصق) وجزء (لفظ الجلالة/رب) من غير ما نفقد التشكيل الأصلي.
int _originalIndexAfterBaseLetters(String word, int baseLetterCount) {
  var seen = 0;
  for (var i = 0; i < word.length; i++) {
    if (!_diacriticsRegex.hasMatch(word[i])) {
      if (seen == baseLetterCount) return i;
      seen++;
    }
  }
  return word.length;
}

List<InlineSpan> _wordSpans(String word, TextStyle baseStyle, TextStyle highlightStyle) {
  if (word.isEmpty) return [TextSpan(text: word, style: baseStyle)];
  final bareWord = _stripDiacritics(word);
  final prefixLength = _allahOrRabbPrefixLength(bareWord);
  if (prefixLength == null) {
    return [TextSpan(text: word, style: baseStyle)];
  }
  if (prefixLength == 0) {
    return [TextSpan(text: word, style: highlightStyle)];
  }
  final splitAt = _originalIndexAfterBaseLetters(word, prefixLength);
  return [
    TextSpan(text: word.substring(0, splitAt), style: baseStyle),
    TextSpan(text: word.substring(splitAt), style: highlightStyle),
  ];
}

/// يفصّل نص الآية كاملة لكلمات ويلوّن كل كلمة تعود على الله عز وجل (راجع التعليق فوق).
List<InlineSpan> _spansWithHighlightedAllah(String text, TextStyle baseStyle) {
  final highlightStyle = baseStyle.copyWith(color: const Color(0xFFB5442E));
  final words = text.split(' ');
  final spans = <InlineSpan>[];
  for (var i = 0; i < words.length; i++) {
    spans.addAll(_wordSpans(words[i], baseStyle, highlightStyle));
    if (i != words.length - 1) {
      spans.add(TextSpan(text: ' ', style: baseStyle));
    }
  }
  return spans;
}

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  double _fontSize = 22.0;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  String? _reciterName;

  // بدل ما المستخدم يرجع لقائمة السور لما يخلّص سورة، بنكمّل تلقائيًا
  // على السورة اللي بعدها في نفس الصفحة، بالظبط زي تصفّح المصحف الورقي.
  late final List<int> _loadedSurahs;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _loadedSurahs = [widget.surahNumber];
    _scrollController = ScrollController()..addListener(_maybeLoadNextSurah);
    _loadReciter();
    QuranAudioService.instance.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (state == PlayerState.playing) _isLoadingAudio = false;
      });
    });
  }

  void _maybeLoadNextSurah() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final lastLoaded = _loadedSurahs.last;
    if (lastLoaded >= 114) return;
    // نحمّل السورة اللي بعدها لما القارئ يقرب من آخر السورة الحالية،
    // عشان يلاقيها جاهزة على طول من غير ما يحس بوقفة.
    if (position.pixels >= position.maxScrollExtent - 700) {
      setState(() => _loadedSurahs.add(lastLoaded + 1));
    }
  }

  Future<void> _loadReciter() async {
    final saved = await SettingsService.instance.getQuranReciter();
    if (mounted) setState(() => _reciterName = saved?['name']);
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await QuranAudioService.instance.pause();
      return;
    }
    final saved = await SettingsService.instance.getQuranReciter();
    // لو المستخدم لسه مختارش قارئ من مكتبة القراءات، نستخدم قارئ افتراضي معروف
    final server = saved?['server'] ?? 'https://server8.mp3quran.net/afs/';
    setState(() => _isLoadingAudio = true);
    final ok = await QuranAudioService.instance
        .playSurah(server, widget.surahNumber);
    if (!ok && mounted) {
      setState(() => _isLoadingAudio = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تشغيل الصوت، تأكد من اتصال الإنترنت')),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    QuranAudioService.instance.stop();
    super.dispose();
  }

  Widget _buildSurahBlock(int surahNum) {
    final verseCount = quran.getVerseCount(surahNum);
    final surahName = quran.getSurahNameArabic(surahNum);
    final place = quran.getPlaceOfRevelation(surahNum) == 'Makkah' ? 'مكية' : 'مدنية';

    final verseStyle = TextStyle(
      fontFamily: 'AmiriQuran',
      fontSize: _fontSize,
      height: 2.3,
      color: _kMushafInk,
    );

    // نبني كل آيات السورة كنص واحد متصل (بنفس أسلوب تدفّق صفحة المصحف)
    // بدل ما تكون كل آية فقرة منفصلة.
    final verseSpans = <InlineSpan>[];
    for (var i = 0; i < verseCount; i++) {
      final verseNum = i + 1;
      final verseText = quran.getVerse(surahNum, verseNum, verseEndSymbol: false);
      verseSpans.addAll(_spansWithHighlightedAllah(verseText, verseStyle));
      verseSpans.add(TextSpan(
        text: ' ${_ayahEndMarker(verseNum)} ',
        style: verseStyle.copyWith(color: _kMushafBorder, fontWeight: FontWeight.bold),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: _kMushafBorder, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(color: _kMushafBorder.withOpacity(0.5), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                // شريط عنوان السورة الزخرفي
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _kMushafGreen.withOpacity(0.08),
                    border: Border.all(color: _kMushafBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('❋', style: TextStyle(color: _kMushafBorder, fontSize: 16)),
                      const SizedBox(width: 10),
                      Text(
                        'سورة $surahName',
                        style: const TextStyle(
                          fontFamily: 'AmiriQuran',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _kMushafGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('❋', style: TextStyle(color: _kMushafBorder, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$place • $verseCount آية • ترتيبها $surahNum',
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 13, color: _kMushafInk.withOpacity(0.65)),
                ),
                const SizedBox(height: 20),

                // البسملة (لكل السور ما عدا التوبة)
                if (surahNum != 9)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 28,
                        color: _kMushafGreen,
                      ),
                    ),
                  ),

                // نص السورة متصلاً، بنفس تدفّق صفحة المصحف
                Text.rich(
                  TextSpan(children: verseSpans),
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerSurahName = quran.getSurahNameArabic(widget.surahNumber);

    return Scaffold(
      backgroundColor: _kMushafPaper,
      appBar: AppBar(
        title: Text(headerSurahName, style: const TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoadingAudio
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
            tooltip: _reciterName != null
                ? 'تشغيل بصوت $_reciterName'
                : 'تشغيل السورة (اختر قارئ من مكتبة القراءات)',
            onPressed: _togglePlay,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'تكبير الخط',
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(16.0, 36.0)),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'تصغير الخط',
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(16.0, 36.0)),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(14),
        itemCount: _loadedSurahs.length,
        itemBuilder: (context, index) => _buildSurahBlock(_loadedSurahs[index]),
      ),
    );
  }
}
