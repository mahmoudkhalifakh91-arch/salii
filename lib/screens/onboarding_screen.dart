import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';
import '../services/app_block_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

const _kGreen = Color(0xFF0F5132);
const _kBg = Color(0xFFF7F7F5);

/// شاشات الترحيب اللي بتظهر أول مرة بس بعد تثبيت التطبيق: بتشرح فايدة
/// التنبيهات وقفل التطبيقات المشتتة، وبتاخد إذن المستخدم صلاحيات النظام
/// اللازمة (الإشعارات، الظهور فوق التطبيقات الأخرى، خدمة إمكانية الوصول)
/// بطريقة تدريجية ومشروحة بدل ما تظهر فجأة من غير سياق.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _step = 0;
  int _reminderMinutes = 10;
  bool _busy = false;

  static const int _totalSteps = 7;

  Future<void> _goTo(int step) async {
    setState(() => _step = step);
    await _controller.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  Future<void> _next() async {
    if (_step >= _totalSteps - 1) {
      await _finish();
      return;
    }
    await _goTo(_step + 1);
  }

  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    // نضمن إن أذونات النظام اتطلبت مرة على الأقل حتى لو المستخدم تخطى
    // كل شاشات الأذونات الفردية بـ"ربما لاحقًا".
    await NotificationService.instance.requestRuntimePermissions();
    await SettingsService.instance.setOnboardingComplete(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildProgress(),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ValueStep(
                    icon: Icons.notifications_off_outlined,
                    title: 'قد يفوتك تنبيه الصلاة بسهولة',
                    subtitle: 'قد تغطيه الإشعارات الأخرى بسرعة وسط زحمة تطبيقاتك.',
                    onNext: _next,
                  ),
                  _ValueStep(
                    icon: Icons.shield_moon_outlined,
                    title: 'صلّي يوقف التطبيقات المشتتة وقت الصلاة',
                    subtitle: 'امنع نفسك من فتح تيك توك وإنستجرام وغيرهم لحظة الأذان.',
                    onNext: _next,
                  ),
                  _ReminderStep(
                    selected: _reminderMinutes,
                    onSelect: (v) => setState(() => _reminderMinutes = v),
                    onNext: () async {
                      await SettingsService.instance
                          .setReminderMinutesBeforeAdhan(_reminderMinutes);
                      await _next();
                    },
                  ),
                  _PermissionStep(
                    icon: Icons.layers_outlined,
                    title: 'أظهر تذكير الصلاة فوق التطبيقات الأخرى',
                    subtitle: 'ليظهر التذكير عندما تحتاج إليه، حتى لو كنت مستخدمًا تطبيقًا آخر.',
                    onAllow: () async {
                      await AppBlockService.instance.requestOverlayPermission();
                      await _next();
                    },
                    onSkip: _next,
                  ),
                  _PermissionStep(
                    icon: Icons.security_outlined,
                    title: 'إذن قفل التطبيقات وقت الصلاة',
                    subtitle:
                        'يُستخدم هذا الإذن فقط لقفل التطبيقات عند حلول وقت الصلاة. لا نقرأ أو نرى أو نخزّن أي شيء يظهر على شاشتك.',
                    onAllow: () async {
                      await AppBlockService.instance
                          .requestAccessibilityPermission();
                      await _next();
                    },
                    onSkip: _next,
                  ),
                  _PermissionStep(
                    icon: Icons.notifications_active_outlined,
                    title: 'احصل على تنبيه قبل وقت الصلاة',
                    subtitle: 'لتستعد قبل الأذان بالوقت اللي اخترته.',
                    onAllow: () async {
                      await NotificationService.instance
                          .requestRuntimePermissions();
                      await _next();
                    },
                    onSkip: _next,
                  ),
                  _FinalStep(busy: _busy, onStart: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    if (_step >= _totalSteps - 1) return const SizedBox(height: 12);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _finish,
            child: const Text('تخطي', style: TextStyle(color: Colors.grey)),
          ),
          Text(
            'خطوة ${_step + 1} من $_totalSteps',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    if (_step >= _totalSteps - 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: List.generate(_totalSteps - 1, (i) {
          final active = i <= _step;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active ? _kGreen : Colors.grey.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ValueStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onNext;

  const _ValueStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: _kGreen),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
          ),
          const SizedBox(height: 40),
          _PrimaryButton(label: 'التالي', onTap: onNext),
        ],
      ),
    );
  }
}

class _ReminderStep extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  const _ReminderStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const options = [5, 10, 15, 30];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Text('ذكّرني قبل الأذان', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('اختر وقت التذكير الذي يناسبك قبل كل صلاة.', style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 24),
          ...options.map((m) {
            final active = m == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSelect(m),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: active ? _kGreen : Colors.grey.withOpacity(0.2), width: active ? 2 : 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(active ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: active ? _kGreen : Colors.grey),
                      Text('$m د', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          _PrimaryButton(label: 'التالي', onTap: onNext),
        ],
      ),
    );
  }
}

class _PermissionStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onAllow;
  final VoidCallback onSkip;

  const _PermissionStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAllow,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
            ),
            child: Icon(icon, size: 56, color: _kGreen),
          ),
          const SizedBox(height: 28),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.7)),
          const SizedBox(height: 32),
          _PrimaryButton(label: 'السماح', onTap: onAllow),
          const SizedBox(height: 10),
          TextButton(onPressed: onSkip, child: const Text('ربما لاحقًا', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class _FinalStep extends StatelessWidget {
  final bool busy;
  final VoidCallback onStart;

  const _FinalStep({required this.busy, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kGreen,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤍', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 16),
            const Text(
              'الحمد لله',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'صلِّ، ثم سجّلها بضغطة واحدة، وأكمل يومك.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: busy ? null : onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: busy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('ابدأ الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
