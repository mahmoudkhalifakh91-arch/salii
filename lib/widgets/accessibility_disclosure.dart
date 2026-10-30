import 'package:flutter/material.dart';

/// الإفصاح الصريح (Prominent Disclosure) المطلوب من Google Play قبل فتح
/// إعدادات خدمة إمكانية الوصول. بيرجع true فقط لو المستخدم وافق صراحةً.
/// لازم يُستدعى قبل أي طلب لصلاحية Accessibility.
Future<bool> confirmAccessibilityDisclosure(BuildContext context) async {
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('استخدام خدمة إمكانية الوصول'),
        content: const SingleChildScrollView(
          child: Text(
            'ميزة «الوقف الذكي» في صلّي تستخدم خدمة إمكانية الوصول (Accessibility) '
            'لغرض واحد فقط: معرفة اسم التطبيق الذي يُفتح على الشاشة، فإذا كان '
            'من التطبيقات التي اخترتَ قفلها وقت الصلاة، تُعرض شاشة القفل فوقه.\n\n'
            'ما الذي نصل إليه؟ اسم حزمة التطبيق المفتوح فقط.\n'
            'ما الذي لا نفعله؟ لا نقرأ ما يظهر على شاشتك، ولا نسجّل ما تكتبه، '
            'ولا نجمع أي بيانات أو نرسلها لأي جهة، ولا ننفّذ نقرات نيابةً عنك.\n\n'
            'هذه الخدمة اختيارية تمامًا، ولا تعمل إلا إذا فعّلتها بنفسك من '
            'إعدادات الجهاز، ويمكنك إيقافها في أي وقت. ولن يتأثر باقي التطبيق '
            '(المواقيت والأذان والمصحف) إذا رفضتها.',
            style: TextStyle(height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('لا أوافق'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('أوافق وأكمل'),
          ),
        ],
      ),
    ),
  );
  return accepted ?? false;
}
