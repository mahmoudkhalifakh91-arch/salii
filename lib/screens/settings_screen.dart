import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _calcMethod = 'egypt';
  String _muezzin = 'abdul_basit';
  bool _notificationsEnabled = true;
  bool _useGPS = true;
  bool _loading = true;
  bool _previewingSound = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final calcMethod = await SettingsService.instance.getCalcMethod();
    final muezzin = await SettingsService.instance.getMuezzin();
    final notificationsEnabled =
        await SettingsService.instance.getNotificationsEnabled();
    final useGps = await SettingsService.instance.getUseGps();

    if (!mounted) return;
    setState(() {
      _calcMethod = calcMethod;
      _muezzin = muezzin;
      _notificationsEnabled = notificationsEnabled;
      _useGPS = useGps;
      _loading = false;
    });
  }

  /// يعيد حساب مواقيت اليوم بالإعدادات الجديدة ويعيد جدولة الإشعارات فوراً،
  /// حتى ينعكس أي تغيير (طريقة الحساب / تفعيل الإشعارات) من غير ما ينتظر المستخدم يرجع لشاشة المواقيت.
  Future<void> _rescheduleNotifications() async {
    if (!_notificationsEnabled) {
      await NotificationService.instance.cancelAll();
      return;
    }
    final location = await LocationService.instance.getCurrentLocation();
    final prayers = PrayerService.calculateTodayPrayers(
      latitude: location.latitude,
      longitude: location.longitude,
      methodKey: _calcMethod,
    );
    final toSchedule = prayers.any((p) => p.isNext)
        ? prayers
        : PrayerService.calculateTodayPrayers(
            latitude: location.latitude,
            longitude: location.longitude,
            methodKey: _calcMethod,
            forDate: DateTime.now().add(const Duration(days: 1)),
          );
    await NotificationService.instance
        .scheduleForPrayers(toSchedule, muezzinId: _muezzin);
  }

  Future<void> _previewMuezzinSound() async {
    if (_previewingSound) return;
    setState(() => _previewingSound = true);
    final ok = await AudioService.instance.playAdhan(_muezzin);
    if (!mounted) return;
    setState(() => _previewingSound = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الملف الصوتي غير متوفر بعد — أضف ملفات الأذان في assets/audio/',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section 1: Prayer Calculations
                _buildSectionHeader('حساب المواقيت والمؤذن'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _calcMethod,
                        decoration: const InputDecoration(
                          labelText: 'طريقة حساب المواقيت',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'egypt', child: Text('الهيئة المصرية العامة للمساحة')),
                          DropdownMenuItem(value: 'umm_al_qura', child: Text('جامعة أم القرى (مكة المكرمة)')),
                          DropdownMenuItem(value: 'mwl', child: Text('رابطة العالم الإسلامي')),
                          DropdownMenuItem(value: 'isna', child: Text('الجمعية الإسلامية لأمريكا الشمالية')),
                        ],
                        onChanged: (v) async {
                          final method = v ?? 'egypt';
                          setState(() => _calcMethod = method);
                          await SettingsService.instance.setCalcMethod(method);
                          await _rescheduleNotifications();
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _muezzin,
                        decoration: const InputDecoration(
                          labelText: 'صوت مؤذن التنبيهات',
                          border: OutlineInputBorder(),
                        ),
                        items: AudioService.availableMuezzins
                            .map((m) => DropdownMenuItem(
                                  value: m['id'],
                                  child: Text(m['label']!),
                                ))
                            .toList(),
                        onChanged: (v) async {
                          final muezzin = v ?? 'abdul_basit';
                          setState(() => _muezzin = muezzin);
                          await SettingsService.instance.setMuezzin(muezzin);
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _previewingSound ? null : _previewMuezzinSound,
                          icon: Icon(
                            _previewingSound
                                ? Icons.hourglass_top
                                : Icons.play_circle_outline,
                            size: 20,
                          ),
                          label: const Text('تجربة الصوت'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2: Location & Notifications
                _buildSectionHeader('الموقع والتنبيهات'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0F5132),
                        title: const Text('تحديد الموقع تلقائياً (GPS)'),
                        subtitle: const Text('حساب مواقيت الصلاة بدقة حسب مكانك الفعلي'),
                        value: _useGPS,
                        onChanged: (v) async {
                          setState(() => _useGPS = v);
                          await SettingsService.instance.setUseGps(v);
                          await _rescheduleNotifications();
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0F5132),
                        title: const Text('تنبيهات الأذان'),
                        subtitle: const Text('إرسال إشعار عند دخول وقت كل صلاة'),
                        value: _notificationsEnabled,
                        onChanged: (v) async {
                          setState(() => _notificationsEnabled = v);
                          await SettingsService.instance
                              .setNotificationsEnabled(v);
                          await _rescheduleNotifications();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 3: About
                _buildSectionHeader('حول تطبيق صلي'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5132).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0F5132).withOpacity(0.2)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تطبيق صلي (Salli)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F5132)),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'تطبيق إسلامي مجاني وخالٍ من الإعلانات تماماً. يعمل بنسبة 100% بدون إنترنت لحساب مواقيت الصلاة، قراءة المصحف الشريف، الأذكار والمسبحة، وبوصلة القبلة.',
                        style: TextStyle(fontSize: 13, height: 1.6, color: Colors.black87),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'الإصدار 1.0.0 • بنية Flutter الأصلية',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
