import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../services/quran_audio_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';

const _brandGreen = Color(0xFF0F5132);

class SoundLibraryScreen extends StatefulWidget {
  const SoundLibraryScreen({super.key});

  @override
  State<SoundLibraryScreen> createState() => _SoundLibraryScreenState();
}

class _SoundLibraryScreenState extends State<SoundLibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    AudioService.instance.stop();
    QuranAudioService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('مكتبة القراءات'),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'أذان'),
            Tab(text: 'قرآن كريم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AdhanRecitersTab(),
          _QuranRecitersTab(),
        ],
      ),
    );
  }
}

class _AdhanRecitersTab extends StatefulWidget {
  const _AdhanRecitersTab();

  @override
  State<_AdhanRecitersTab> createState() => _AdhanRecitersTabState();
}

class _AdhanRecitersTabState extends State<_AdhanRecitersTab> {
  String? _selected;
  String? _previewing;

  @override
  void initState() {
    super.initState();
    SettingsService.instance.getMuezzin().then((v) {
      if (mounted) setState(() => _selected = v);
    });
  }

  Future<void> _select(String id) async {
    setState(() => _selected = id);
    await SettingsService.instance.setMuezzin(id);
  }

  Future<void> _preview(String id) async {
    setState(() => _previewing = id);
    final ok = await AudioService.instance.playAdhan(id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تشغيل الصوت — الملف غير موجود')),
      );
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _previewing = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: AudioService.availableMuezzins.length,
      itemBuilder: (context, index) {
        final m = AudioService.availableMuezzins[index];
        final id = m['id']!;
        final isSelected = _selected == id;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.brand(context) : AppColors.border(context),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? AppColors.brandTint(context)
                  : AppColors.elevated(context),
              child: Icon(Icons.mic_rounded,
                  color: isSelected ? AppColors.brand(context) : AppColors.muted(context)),
            ),
            title: Text(m['label']!, style: const TextStyle(fontSize: 14)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _previewing == id
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_fill_rounded,
                    color: AppColors.brand(context),
                  ),
                  onPressed: () => _preview(id),
                ),
                Radio<String>(
                  value: id,
                  groupValue: _selected,
                  activeColor: AppColors.brand(context),
                  onChanged: (v) => _select(v!),
                ),
              ],
            ),
            onTap: () => _select(id),
          ),
        );
      },
    );
  }
}

class _QuranRecitersTab extends StatefulWidget {
  const _QuranRecitersTab();

  @override
  State<_QuranRecitersTab> createState() => _QuranRecitersTabState();
}

class _QuranRecitersTabState extends State<_QuranRecitersTab> {
  List<QuranReciter>? _reciters;
  String? _selectedId;
  String? _playingId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final saved = await SettingsService.instance.getQuranReciter();
    try {
      final reciters = await QuranAudioService.instance.fetchReciters();
      if (!mounted) return;
      setState(() {
        _reciters = reciters;
        _selectedId = saved?['id'];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل قائمة القرّاء، تأكد من اتصالك بالإنترنت';
        _loading = false;
      });
    }
  }

  Future<void> _select(QuranReciter r) async {
    setState(() => _selectedId = r.id);
    await SettingsService.instance.setQuranReciter(r.id, r.name, r.server);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اتحدد ${r.name} قارئ افتراضي لتشغيل السور')),
      );
    }
  }

  Future<void> _previewFatiha(QuranReciter r) async {
    setState(() => _playingId = r.id);
    final ok = await QuranAudioService.instance.playSurah(r.server, 1);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تشغيل الصوت، تأكد من اتصال الإنترنت')),
      );
      setState(() => _playingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.faint(context)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    final reciters = _reciters ?? [];
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.brandTint(context),
          padding: const EdgeInsets.all(12),
          child: Text(
            'اختر قارئك المفضل لتشغيل السور كاملة داخل شاشة المصحف. التشغيل يحتاج اتصال إنترنت.',
            style: TextStyle(fontSize: 12, color: AppColors.text(context)),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              final r = reciters[index];
              final isSelected = _selectedId == r.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.brand(context) : AppColors.border(context),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? AppColors.brandTint(context)
                        : AppColors.elevated(context),
                    child: Icon(Icons.menu_book_rounded,
                        color: isSelected ? AppColors.brand(context) : AppColors.muted(context)),
                  ),
                  title: Text(r.name, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(r.rewayah, style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _playingId == r.id
                              ? Icons.stop_circle_rounded
                              : Icons.play_circle_fill_rounded,
                          color: AppColors.brand(context),
                        ),
                        tooltip: 'تجربة (الفاتحة)',
                        onPressed: () => _previewFatiha(r),
                      ),
                      Radio<String>(
                        value: r.id,
                        groupValue: _selectedId,
                        activeColor: AppColors.brand(context),
                        onChanged: (_) => _select(r),
                      ),
                    ],
                  ),
                  onTap: () => _select(r),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
