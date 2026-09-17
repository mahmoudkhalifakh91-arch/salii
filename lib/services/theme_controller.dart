import 'package:flutter/material.dart';
import 'settings_service.dart';

/// يتحكم في وضع الإضاءة (فاتح/ليلي) للتطبيق كله، ويحفظ اختيار المستخدم
/// عشان يفضل موجود لما يفتح التطبيق تاني.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  Future<void> load() async {
    final isDark = await SettingsService.instance.getDarkMode();
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle(bool enableDark) async {
    mode.value = enableDark ? ThemeMode.dark : ThemeMode.light;
    await SettingsService.instance.setDarkMode(enableDark);
  }

  bool get isDark => mode.value == ThemeMode.dark;
}
