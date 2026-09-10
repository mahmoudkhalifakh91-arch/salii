import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/main_navigation_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة خدمة الإشعارات مبكراً (مناطق زمنية + أذونات) قبل تشغيل الواجهة
  await NotificationService.instance.initialize();
  runApp(const SalliApp());
}

class SalliApp extends StatelessWidget {
  const SalliApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFFF9FAF8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F5132), // Deep Islamic Emerald Green
          primary: const Color(0xFF0F5132),
          secondary: const Color(0xFFD4AF37), // Pure Gold
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9FAF8),
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
