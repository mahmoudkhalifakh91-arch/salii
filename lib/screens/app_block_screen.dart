import 'package:flutter/material.dart';

import '../models/blockable_app_model.dart';
import '../services/app_block_service.dart';
import '../services/settings_service.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';

const _brandGreen = Color(0xFF0F5132);

class AppBlockScreen extends StatefulWidget {
  const AppBlockScreen({super.key});

  @override
  State<AppBlockScreen> createState() => _AppBlockScreenState();
}

class _AppBlockScreenState extends State<AppBlockScreen>
    with WidgetsBindingObserver {
  bool _loading = true;

  bool _overlayGranted = false;
  bool _accessibilityGranted = false;
  bool _usageStatsGranted = false;

  bool _masterEnabled = false;
  final Set<String> _selectedPackages = {};

  bool get _allPermissionsGranted =>
      _overlayGranted && _accessibilityGranted && _usageStatsGranted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // المستخدم بيرجع للتطبيق بعد ما يفتح شاشة أذونات أندرويد من برّه،
  // فلازم نعيد فحص حالة الأذونات كل ما التطبيق يرجع للمقدمة.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _load() async {
    final toggled = await AppBlockService.instance.getToggledApps();
    final masterEnabled = await SettingsService.instance.getAppBlockEnabled();
    await _refreshPermissions(rebuild: false);
    if (!mounted) return;
    setState(() {
      _selectedPackages
        ..clear()
        ..addAll(toggled);
      _masterEnabled = masterEnabled;
      _loading = false;
    });
  }

  Future<void> _refreshPermissions({bool rebuild = true}) async {
    final overlay = await AppBlockService.instance.hasOverlayPermission();
    final accessibility =
        await AppBlockService.instance.isAccessibilityServiceEnabled();
    final usageStats = await AppBlockService.instance.hasUsageStatsPermission();
    if (!mounted) return;
    setState(() {
      _overlayGranted = overlay;
      _accessibilityGranted = accessibility;
      _usageStatsGranted = usageStats;
    });
  }

  Future<void> _toggleApp(String packageName, bool value) async {
    setState(() {
      if (value) {
        _selectedPackages.add(packageName);
      } else {
        _selectedPackages.remove(packageName);
      }
    });
    await AppBlockService.instance
        .setToggledApps(_selectedPackages.toList());
    // لو المستخدم لغى تحديد تطبيق، نلغي أي قفل حالي عليه فورًا كمان
    if (!value) {
      await AppBlockService.instance.unlockApp(packageName);
    }
  }

  Future<void> _toggleMaster(bool value) async {
    if (value && !_allPermissionsGranted) {
      _showPermissionsRequiredSnackbar();
      return;
    }
    setState(() => _masterEnabled = value);
    await SettingsService.instance.setAppBlockEnabled(value);
    if (value) {
      await _scheduleTodayBlocks();
    }
  }

  Future<void> _scheduleTodayBlocks() async {
    try {
      final location = await LocationService.instance.getCurrentLocation();
      final prayers = PrayerService.calculateTodayPrayers(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      await AppBlockService.instance
          .schedulePrayerBlocks(prayers.map((p) => p.time).toList());
    } catch (_) {
      // لو تعذّر تحديد الموقع دلوقتي، هيتجدول تاني تلقائياً أول ما
      // المستخدم يفتح شاشة الإعدادات أو مواقيت الصلاة
    }
  }

  void _showPermissionsRequiredSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('لازم تفعّل الأذونات التلاتة فوق الأول عشان تقدر تشغّل الوقف الذكي'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('نظام تقييد التطبيقات وأذونات الهاتف'),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPermissionsCard(),
                const SizedBox(height: 20),
                _buildAppsCard(),
                const SizedBox(height: 20),
                _buildMasterSwitchCard(),
              ],
            ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: child,
    );
  }

  Widget _buildPermissionsCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعداد أذونات نظام الهاتف المطلوبة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'لازم توافق على الأذونات التلاتة دي عشان تطبيق صلّي يقدر يقفل التطبيقات المشتتة تلقائياً وقت الصلاة',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 12),
          _permissionRow(
            title: 'إذن الظهور فوق التطبيقات الأخرى (System Overlay)',
            subtitle: 'يسمح بعرض رسالة تنبيه لحظة قفل التطبيق المشتت',
            granted: _overlayGranted,
            onTap: () async {
              await AppBlockService.instance.requestOverlayPermission();
            },
          ),
          const Divider(height: 24),
          _permissionRow(
            title: 'خدمة إمكانية الوصول (Accessibility Service)',
            subtitle: 'تمكّن نظام صلّي من رصد وإغلاق التطبيقات المحظورة فوراً',
            granted: _accessibilityGranted,
            onTap: () async {
              await AppBlockService.instance.requestAccessibilityPermission();
            },
          ),
          const Divider(height: 24),
          _permissionRow(
            title: 'الوصول لإحصائيات الاستخدام (Usage Stats Access)',
            subtitle: 'يسمح للتطبيق بمعرفة التطبيق الشغّال حالياً في المقدمة',
            granted: _usageStatsGranted,
            onTap: () async {
              await AppBlockService.instance.requestUsageStatsPermission();
            },
          ),
        ],
      ),
    );
  }

  Widget _permissionRow({
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: granted ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                granted ? 'مفعل بنجاح' : 'غير مفعل',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: granted ? Colors.green.shade800 : Colors.red.shade700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (!granted)
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('فعّل الآن', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppsCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحديد التطبيقات المفيدة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'حدد التطبيقات اللي عايز تتقفل تلقائياً مع دخول وقت كل صلاة، ومش هتفتح تاني إلا لو لغيت القفل من هنا بنفسك',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 8),
          ...kBlockableApps.map((app) {
            final selected = _selectedPackages.contains(app.packageName);
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.red.shade400,
              secondary: CircleAvatar(
                backgroundColor: selected
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.12),
                child: Icon(app.icon, color: selected ? Colors.red.shade400 : Colors.grey.shade600, size: 20),
              ),
              title: Text(app.nameAr, style: const TextStyle(fontSize: 14)),
              value: selected,
              onChanged: (v) => _toggleApp(app.packageName, v),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMasterSwitchCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _brandGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_moon_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'الوقف الذكي',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Switch(
                value: _masterEnabled,
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.4),
                onChanged: _toggleMaster,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _masterEnabled
                ? 'مفعّل — التطبيقات اللي حددتها هتتقفل تلقائياً مع كل أذان، ومش هترجع تفتح إلا من الشاشة دي.'
                : 'لما تفعّله، أي تطبيق تحدده هيتقفل تلقائياً لحظة دخول وقت الصلاة، ومش هيفتح تاني غير من هنا.',
            style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.6),
          ),
          if (!_allPermissionsGranted) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'محتاج تفعّل الأذونات التلاتة فوق الأول',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
