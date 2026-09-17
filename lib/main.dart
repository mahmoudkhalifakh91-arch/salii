import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة خدمة الإشعارات مبكراً (مناطق زمنية + أذونات) قبل تشغيل الواجهة
  await NotificationService.instance.initialize();
  // تحميل وضع الإضاءة المحفوظ (فاتح/ليلي) قبل رسم أول شاشة
  await ThemeController.instance.load();
  runApp(const SalliApp());
}

class SalliApp extends StatelessWidget {
  const SalliApp({super.key});

  static const _brandGreen = Color(0xFF0F5132);
  static const _brandGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'صلي',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'EG'),
          supportedLocales: const [
            Locale('ar', 'EG'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'sans-serif',
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF9FAF8),
            colorScheme: ColorScheme.fromSeed(
              seedColor: _brandGreen,
              brightness: Brightness.light,
              primary: _brandGreen,
              secondary: _brandGold,
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF9FAF8),
              elevation: 0,
              foregroundColor: Colors.black87,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'sans-serif',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(
              seedColor: _brandGreen,
              brightness: Brightness.dark,
              primary: const Color(0xFF4CAF7D),
              secondary: _brandGold,
              surface: const Color(0xFF1E1E1E),
            ),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F5132),
              elevation: 0,
              foregroundColor: Colors.white,
            ),
          ),
          home: const _AppEntryPoint(),
        );
      },
    );
  }
}

/// يقرر أول شاشة تظهر: شاشات الترحيب (أول مرة بعد التثبيت بس)، أو الشاشة
/// الرئيسية مباشرة لو المستخدم خلّص الترحيب قبل كده.
class _AppEntryPoint extends StatelessWidget {
  const _AppEntryPoint();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SettingsService.instance.getOnboardingComplete(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF7F7F5),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const MainNavigationScreen() : const OnboardingScreen();
      },
    );
  }
}
