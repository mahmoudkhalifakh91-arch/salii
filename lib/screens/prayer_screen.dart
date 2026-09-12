import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/prayer_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../models/prayer_model.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  List<PrayerInfo> _prayers = [];
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  PrayerInfo? _nextPrayer;
  bool _loading = true;
  String _locationLabel = '';
  bool _locationIsFallback = false;

  @override
  void initState() {
    super.initState();
    _loadPrayers();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayers() async {
    setState(() => _loading = true);

    final location = await LocationService.instance.getCurrentLocation();
    final calcMethod = await SettingsService.instance.getCalcMethod();
    final notificationsEnabled =
        await SettingsService.instance.getNotificationsEnabled();

    final prayers = PrayerService.calculateTodayPrayers(
      latitude: location.latitude,
      longitude: location.longitude,
      methodKey: calcMethod,
    );

    if (!mounted) return;
    setState(() {
      _prayers = prayers;
      _locationLabel = location.cityLabel;
      _locationIsFallback = location.isFallback;
      _nextPrayer = _prayers.firstWhere(
        (p) => p.isNext,
        orElse: () => _prayers.first,
      );
      _loading = false;
    });
    _updateCountdown();

    if (notificationsEnabled) {
      // لو الصلاة القادمة "isNext" رجعت null (يعني كل صلوات اليوم فاتت)،
      // بنجدول بمواقيت بكرة عشان الفجر يتظبط صح
      final toSchedule = _prayers.any((p) => p.isNext)
          ? _prayers
          : PrayerService.calculateTodayPrayers(
              latitude: location.latitude,
              longitude: location.longitude,
              methodKey: calcMethod,
              forDate: DateTime.now().add(const Duration(days: 1)),
            );
      final muezzinId = await SettingsService.instance.getMuezzin();
      await NotificationService.instance
          .scheduleForPrayers(toSchedule, muezzinId: muezzinId);
    } else {
      await NotificationService.instance.cancelAll();
    }
  }

  void _updateCountdown() {
    if (_nextPrayer == null || _prayers.isEmpty) return;
    final now = DateTime.now();
    var diff = _nextPrayer!.time.difference(now);
    if (diff.isNegative) {
      // كل صلوات اليوم فاتت -> نحسب فجر بكرة بدقة بدل رقم تقريبي ثابت
      final tomorrow = PrayerService.calculateTodayPrayers(
        forDate: DateTime.now().add(const Duration(days: 1)),
      );
      final tomorrowFajr = tomorrow.firstWhere((p) => p.id == 'fajr');
      diff = tomorrowFajr.time.difference(now);
    }
    setState(() {
      _timeRemaining = diff;
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPrayers,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading)
              const LinearProgressIndicator(minHeight: 2)
            else if (_locationLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      _locationIsFallback
                          ? Icons.location_off_outlined
                          : Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _locationIsFallback
                            ? 'المواقيت محسوبة على $_locationLabel (فعّل خدمة الموقع لدقة أعلى)'
                            : 'المواقيت محسوبة حسب: $_locationLabel',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            // Next Prayer Hero Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F5132), Color(0xFF1B7A4E)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الصلاة القادمة',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          Text(
                            _nextPrayer?.nameAr ?? '...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _nextPrayer != null
                              ? PrayerService.formatTime(_nextPrayer!.time)
                              : '',
                          style: const TextStyle(
                            color: Color(0xFF0F5132),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'متبقي ${_formatDuration(_timeRemaining)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'صلوات اليوم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Prayer Cards List
            ..._prayers.map((prayer) {
              final isNext = prayer.isNext;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isNext
                      ? const Color(0xFF0F5132).withOpacity(0.08)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isNext
                        ? const Color(0xFF0F5132).withOpacity(0.4)
                        : Colors.grey.withOpacity(0.15),
                    width: isNext ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          color: isNext
                              ? const Color(0xFF0F5132)
                              : Colors.grey.shade400,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          prayer.nameAr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isNext ? FontWeight.bold : FontWeight.w600,
                            color: isNext
                                ? const Color(0xFF0F5132)
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      PrayerService.formatTime(prayer.time),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isNext ? FontWeight.bold : FontWeight.w500,
                        color: isNext
                            ? const Color(0xFF0F5132)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
