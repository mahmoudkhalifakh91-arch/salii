import 'package:flutter/material.dart';
import 'prayer_screen.dart';
import 'quran_screen.dart';
import 'azkar_screen.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';

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
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: const Color(0xFF0F5132).withOpacity(0.15),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time),
            selectedIcon: Icon(Icons.access_time_filled, color: Color(0xFF0F5132)),
            label: 'المواقيت',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF0F5132)),
            label: 'المصحف',
          ),
          NavigationDestination(
            icon: Icon(Icons.fingerprint),
            selectedIcon: Icon(Icons.fingerprint, color: Color(0xFF0F5132)),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: Color(0xFF0F5132)),
            label: 'القبلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFF0F5132)),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
