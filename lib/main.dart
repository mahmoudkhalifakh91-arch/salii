import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'services/theme_controller.dart';
import 'theme/app_colors.dart';

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
            // خلفية رمادية مخضرّة خفيفة بدل الأسود الصريح — أريح للعين
            scaffoldBackgroundColor: const Color(0xFF11150F),
            colorScheme: ColorScheme.fromSeed(
              seedColor: _brandGreen,
              brightness: Brightness.dark,
              primary: AppColors.brandDark,
              onPrimary: const Color(0xFF07130D),
              secondary: _brandGold,
              surface: const Color(0xFF1B211F),
              onSurface: const Color(0xFFE9EEEB),
            ),
            cardColor: const Color(0xFF1B211F),
            dividerColor: Colors.white.withOpacity(0.08),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF16311F),
              elevation: 0,
              foregroundColor: Color(0xFFE9EEEB),
            ),
            // نصوص أفتح وارتفاع سطر أوسع = قراءة أريح في الليل
            textTheme: Typography.whiteMountainView.apply(
              bodyColor: const Color(0xFFE9EEEB),
              displayColor: const Color(0xFFE9EEEB),
            ),
            listTileTheme: const ListTileThemeData(
              textColor: Color(0xFFE9EEEB),
              iconColor: Color(0xFFA3AFA9),
              subtitleTextStyle: TextStyle(
                color: Color(0xFFA3AFA9),
                fontSize: 12.5,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFFCBD5CF)),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: const TextStyle(color: Color(0xFFA3AFA9)),
              hintStyle: const TextStyle(color: Color(0xFF8A958F)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.brandDark, width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
              ),
            ),
            dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(color: Color(0xFFE9EEEB)),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF1B211F),
              indicatorColor: AppColors.brandDark.withOpacity(0.18),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 11.5, color: Color(0xFFCBD5CF)),
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color(0xFF242B28),
              contentTextStyle: TextStyle(color: Color(0xFFE9EEEB)),
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
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const MainNavigationScreen() : const OnboardingScreen();
      },
    );
  }
}
