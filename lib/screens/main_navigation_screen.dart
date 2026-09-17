import 'package:flutter/material.dart';
import 'prayer_screen.dart';
import 'quran_screen.dart';
import 'azkar_screen.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';
import '../theme/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PrayerScreen(),
    QuranScreen(),
    AzkarScreen(),
    QiblaScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: AppColors.card(context),
        elevation: 3,
        indicatorColor: AppColors.brand(context).withOpacity(0.18),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.access_time),
            selectedIcon: Icon(Icons.access_time_filled, color: AppColors.brand(context)),
            label: 'المواقيت',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.brand(context)),
            label: 'المصحف',
          ),
          NavigationDestination(
            icon: const Icon(Icons.fingerprint),
            selectedIcon: Icon(Icons.fingerprint, color: AppColors.brand(context)),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.brand(context)),
            label: 'القبلة',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.brand(context)),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
