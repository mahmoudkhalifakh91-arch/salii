import 'package:flutter/material.dart';

/// ألوان موحّدة للتطبيق تتبدّل تلقائياً بين الوضع الفاتح والوضع الليلي.
/// الهدف إن كل الشاشات تستخدم المصدر ده بدل ما تكتب ألوان ثابتة
/// (أبيض / أسود) تبقى غير مقروءة في الوضع الليلي.
class AppColors {
  const AppColors._();

  /// الأخضر الأساسي في الوضع الفاتح.
  static const Color brandLight = Color(0xFF0F5132);

  /// نسخة أفتح من الأخضر عشان تبان فوق الخلفيات الداكنة.
  static const Color brandDark = Color(0xFF5FCB97);

  static const Color gold = Color(0xFFD4AF37);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// اللون الأخضر الأساسي (يفتح في الوضع الليلي عشان التباين).
  static Color brand(BuildContext context) =>
      isDark(context) ? brandDark : brandLight;

  /// لون الذهبي المستخدم في الإبرازات.
  static Color accent(BuildContext context) =>
      isDark(context) ? const Color(0xFFE5C158) : gold;

  /// خلفية الكروت والصناديق.
  static Color card(BuildContext context) =>
      isDark(context) ? const Color(0xFF1B211F) : Colors.white;

  /// خلفية أعلى شوية من الكارت (للعناصر الداخلية).
  static Color elevated(BuildContext context) =>
      isDark(context) ? const Color(0xFF242B28) : const Color(0xFFF4F6F5);

  /// لون النص الأساسي.
  static Color text(BuildContext context) =>
      isDark(context) ? const Color(0xFFE9EEEB) : Colors.black87;

  /// لون النص الثانوي / الشرح.
  static Color muted(BuildContext context) =>
      isDark(context) ? const Color(0xFFA3AFA9) : Colors.grey.shade600;

  /// لون خفيف للأيقونات غير النشطة.
  static Color faint(BuildContext context) =>
      isDark(context) ? const Color(0xFF6E7B75) : Colors.grey.shade400;

  /// لون الحدود والفواصل.
  static Color border(BuildContext context) => isDark(context)
      ? Colors.white.withOpacity(0.10)
      : Colors.grey.withOpacity(0.15);

  /// خلفية خفيفة بلون البراند (للعناصر المميزة).
  static Color brandTint(BuildContext context) =>
      brand(context).withOpacity(isDark(context) ? 0.16 : 0.08);
}
