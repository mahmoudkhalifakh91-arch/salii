import 'package:flutter/material.dart';

/// ألوان وخطوط موحّدة لكل شاشات "المكتبة الإسلامية" الجديدة، بنفس روح
/// تنسيق صفحة المصحف (خلفية ورقية كريمية + إطار بني ذهبي + خط AmiriQuran/Amiri).
class MushafTheme {
  static const Color paper = Color(0xFFFBF3E1);
  static const Color border = Color(0xFFC9A24B);
  static const Color ink = Color(0xFF1B1B1B);
  static const Color green = Color(0xFF0F5132);
  static const Color highlight = Color(0xFFB5442E);

  static const String quranFont = 'AmiriQuran';
  static const String textFont = 'Amiri';

  static const TextStyle screenTitle = TextStyle(
    fontFamily: textFont,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: quranFont,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: green,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: textFont,
    fontSize: 15,
    height: 1.9,
    color: ink,
  );

  static const TextStyle quranText = TextStyle(
    fontFamily: quranFont,
    fontSize: 22,
    height: 2.2,
    color: ink,
  );

  static BoxDecoration frameDecoration({double radius = 14}) => BoxDecoration(
        color: paper,
        border: Border.all(color: border, width: 1.4),
        borderRadius: BorderRadius.circular(radius),
      );

  static Widget ornateDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text('❋', style: TextStyle(color: border, fontSize: 16)),
      );
}
