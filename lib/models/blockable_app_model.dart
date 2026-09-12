import 'package:flutter/material.dart';

/// تطبيق واحد من التطبيقات المشتتة اللي يقدر المستخدم يحدد إنها تتقفل
/// تلقائياً مع دخول وقت الصلاة. اسم الحزمة (packageName) لازم يكون
/// نفس الاسم الحقيقي لتطبيق أندرويد عشان الـ Accessibility Service يعرف يتعرف عليه.
class BlockableApp {
  final String packageName;
  final String nameAr;
  final IconData icon;

  const BlockableApp({
    required this.packageName,
    required this.nameAr,
    required this.icon,
  });
}

const List<BlockableApp> kBlockableApps = [
  BlockableApp(
    packageName: 'com.zhiliaoapp.musically',
    nameAr: 'تيك توك',
    icon: Icons.music_note_rounded,
  ),
  BlockableApp(
    packageName: 'com.instagram.android',
    nameAr: 'انستجرام',
    icon: Icons.camera_alt_rounded,
  ),
  BlockableApp(
    packageName: 'com.snapchat.android',
    nameAr: 'سناب شات',
    icon: Icons.chat_bubble_rounded,
  ),
  BlockableApp(
    packageName: 'com.google.android.youtube',
    nameAr: 'يوتيوب',
    icon: Icons.smart_display_rounded,
  ),
  BlockableApp(
    packageName: 'com.whatsapp',
    nameAr: 'واتساب',
    icon: Icons.chat_rounded,
  ),
  BlockableApp(
    packageName: 'com.facebook.katana',
    nameAr: 'فيسبوك',
    icon: Icons.facebook_rounded,
  ),
];
