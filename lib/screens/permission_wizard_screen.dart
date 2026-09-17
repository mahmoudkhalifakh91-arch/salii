import 'package:flutter/material.dart';

import '../services/app_block_service.dart';
import '../theme/app_colors.dart';

const _brandGreen = Color(0xFF0F5132);

class _WizardStep {
  final String title;
  final String description;
  final IconData icon;
  final Future<bool> Function() isGranted;
  final Future<void> Function() request;

  const _WizardStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.isGranted,
    required this.request,
  });
}

/// شاشة "خطوة بخطوة" لتفعيل الأذونات الثلاثة المطلوبة لميزة الوقف
/// الذكي، بدل ما المستخدم يدوّر في قائمة طويلة. كل صلاحية في شاشتها
/// المستقلة، وأول ما المستخدم يرجع من إعدادات أندرويد (بعد ما يفعّل
/// الصلاحية من هناك)، الشاشة بتكتشف ده تلقائياً وتنقله للخطوة الجاية
/// لوحدها من غير ما يدوس أي حاجة تانية.
class PermissionWizardScreen extends StatefulWidget {
  const PermissionWizardScreen({super.key});

  @override
  State<PermissionWizardScreen> createState() => _PermissionWizardScreenState();
}

class _PermissionWizardScreenState extends State<PermissionWizardScreen>
    with WidgetsBindingObserver {
  late final List<_WizardStep> _steps;
  int _currentIndex = 0;
  bool _finished = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _steps = [
      _WizardStep(
        title: 'الظهور فوق التطبيقات الأخرى',
        description: 'يسمح بعرض رسالة تنبيه لحظة قفل التطبيق المشتت وقت الصلاة.',
        icon: Icons.layers_rounded,
        isGranted: () => AppBlockService.instance.hasOverlayPermission(),
        request: () => AppBlockService.instance.requestOverlayPermission(),
      ),
      _WizardStep(
        title: 'خدمة إمكانية الوصول',
        description: 'تمكّن نظام صلّي من رصد التطبيقات المشتتة وإغلاقها فوراً وقت الصلاة.',
        icon: Icons.shield_moon_rounded,
        isGranted: () => AppBlockService.instance.isAccessibilityServiceEnabled(),
        request: () => AppBlockService.instance.requestAccessibilityPermission(),
      ),
      _WizardStep(
        title: 'الوصول لإحصائيات الاستخدام',
        description: 'يسمح للتطبيق بمعرفة التطبيق الشغّال حالياً في مقدمة الشاشة.',
        icon: Icons.bar_chart_rounded,
        isGranted: () => AppBlockService.instance.hasUsageStatsPermission(),
        request: () => AppBlockService.instance.requestUsageStatsPermission(),
      ),
    ];
    _skipAlreadyGrantedSteps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // المستخدم بيرجع للتطبيق بعد ما يفعّل الصلاحية من إعدادات أندرويد
  // من برّه — هنا بنفحص هل اتفعلت فعلاً، ولو أيوه ننقله للخطوة الجاية.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_finished) {
      _checkCurrentStep();
    }
  }

  Future<void> _skipAlreadyGrantedSteps() async {
    while (_currentIndex < _steps.length &&
        await _steps[_currentIndex].isGranted()) {
      _currentIndex++;
    }
    if (mounted) {
      setState(() => _finished = _currentIndex >= _steps.length);
    }
  }

  Future<void> _checkCurrentStep() async {
    if (_currentIndex >= _steps.length || _checking) return;
    setState(() => _checking = true);
    final granted = await _steps[_currentIndex].isGranted();
    if (!mounted) return;
    setState(() {
      _checking = false;
      if (granted) {
        _currentIndex++;
        if (_currentIndex >= _steps.length) _finished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إعداد الوقف الذكي'),
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _finished ? _buildDoneView() : _buildStepView(),
      ),
    );
  }

  Widget _buildStepView() {
    final step = _steps[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(_steps.length, (i) {
              final active = i <= _currentIndex;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == _steps.length - 1 ? 0 : 6),
                  height: 5,
                  decoration: BoxDecoration(
                    color: active ? AppColors.brand(context) : AppColors.border(context),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'الخطوة ${_currentIndex + 1} من ${_steps.length}',
            style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: _brandGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, size: 40, color: _brandGreen),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.muted(context), height: 1.6),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _checking
                  ? null
                  : () async {
                      await step.request();
                    },
              child: _checking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('فعّل الآن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'هترجع هنا تلقائياً بعد التفعيل، وهننقلك للخطوة الجاية لوحدنا',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppColors.faint(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 46, color: Colors.green),
          ),
          const SizedBox(height: 24),
          const Text(
            'تمام، كل الأذونات مفعّلة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'دلوقتي تقدر ترجع تحدد التطبيقات وتفعّل الوقف الذكي',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.muted(context)),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('رجوع لإعدادات الوقف الذكي', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
