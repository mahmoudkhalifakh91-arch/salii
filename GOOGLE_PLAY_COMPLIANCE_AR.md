# تقرير جاهزية Google Play — تطبيق صلّي (com.salli.salli_app)

**حالة البناء:** لم يُبنَ AAB في بيئة التدقيق (لا يوجد Flutter/Android SDK ولا شبكة لتنزيلهما). الفحص الذي تم فعلاً: فحص بناء الجملة لكل ملفات Dart/Kotlin/XML فقط. لم يُنفَّذ `flutter analyze` ولا `flutter test` ولا أي اختبار على جهاز.
**الامتثال لسياسات Google Play:** NEEDS ACTION (تصريحات في Play Console مطلوبة — انظر الأسفل). لا ضمان للموافقة.

## 1) الصلاحيات قبل/بعد
| الصلاحية | القرار | السبب |
|---|---|---|
| INTERNET | باقية | صوت القرآن (mp3quran.net) |
| ACCESS_FINE/COARSE_LOCATION | باقية | حساب المواقيت والقبلة محليًا. صلاحية وقت الاستخدام فقط، ولا تُرسل لأي سيرفر |
| POST_NOTIFICATIONS | باقية | إشعارات الأذان (تُطلب وقت التشغيل) |
| SCHEDULE_EXACT_ALARM | باقية | توقيت الأذان الدقيق (تُطلب من المستخدم) |
| USE_EXACT_ALARM | **أُزيلت** | مخصصة لتطبيقات المنبه/التقويم وتحتاج تصريحًا؛ SCHEDULE_EXACT_ALARM تكفي ومعها fallback لإشعار تقريبي |
| USE_FULL_SCREEN_INTENT | باقية | شاشة الأذان فوق القفل. **تحتاج تصريحًا في Play Console** |
| SYSTEM_ALERT_WINDOW | باقية | تسمح بفتح شاشة القفل/الأذان من الخلفية. لو لم تعد مطلوبة بعد اختبارك على أجهزة حقيقية يمكن إزالتها |
| PACKAGE_USAGE_STATS | **أُزيلت** | لا يوجد أي كود يستخدم UsageStatsManager؛ كانت غير مستخدمة فعليًا (وحُذفت خطوتها من واجهة الأذونات) |
| BIND_ACCESSIBILITY_SERVICE (على الخدمة) | باقية | قفل التطبيقات وقت الصلاة. **تحتاج تصريح Accessibility** |
| RECEIVE_BOOT_COMPLETED | باقية، وصارت مستخدمة | BootReceiver جديد يعيد منبهات الأذان والقفل بعد الريستارت |
| VIBRATE / WAKE_LOCK | باقية | عادية، تضيفها الإضافات |
| FOREGROUND_SERVICE* | غير موجودة | لا توجد خدمات foreground |

## 2) خدمة Accessibility
- أُضيفت شاشة إفصاح صريح (Prominent Disclosure) بموافقة/رفض قبل فتح إعدادات الوصول (في الترحيب وفي معالج الأذونات): `lib/widgets/accessibility_disclosure.dart`.
- الخدمة `canRetrieveWindowContent=false`: تقرأ اسم حزمة التطبيق المفتوح فقط، لا محتوى الشاشة، ولا ترسل ولا تخزّن شيئًا.
- لو رُفضت: باقي التطبيق يعمل، وميزة الوقف الذكي فقط تتعطل.
- **مطلوب منك:** تعبئة نموذج Accessibility API في Play Console بوصف الغرض (قفل تطبيقات اختاره المستخدم وقت الصلاة)، وفيديو توضيحي للإفصاح. تأكد ألا يُعرّف التطبيق كأداة لذوي الإعاقة. خطر الرفض قائم لأن الاستخدام ليس لخدمة إعاقة؛ وسياسة Google تسمح بذلك فقط بإفصاح وموافقة وحسب وصفها لـ«الاستخدام الأساسي».

## 3) المنبهات والإشعارات
- نقاط إصلاح: جدولة 7 أيام، إلغاء المنبهات القديمة، fallback للمنبه التقريبي، مستقبلات `flutter_local_notifications` أُضيفت صراحةً في المانيفست، وBootReceiver جديد.
- قنوات الإشعار: أذان (صامت لو شاشة الأذان ستشغل الصوت)، تنبيه قبل الأذان، قناة لكل مؤذن.
- **Exact alarm:** SCHEDULE_EXACT_ALARM قد تتطلب إقرارًا بأن الاستخدام الأساسي هو تنبيهات الصلاة بتوقيت دقيق. USE_FULL_SCREEN_INTENT: Google تقصرها على المكالمات والمنبهات؛ اشرح أن شاشة الأذان تعمل كمنبه ديني.

## 4) الخصوصية وData Safety
- لا يوجد Firebase ولا Google Sign-In ولا Analytics ولا Crashlytics ولا إعلانات في هذا المشروع (تحققت من `pubspec.yaml` والـ Gradle). ملاحظة: طلبك ذكر Google Login وFirebase، لكنهما غير موجودين في الكود الذي أرسلته.
- بيانات تُعالج على الجهاز فقط: الموقع (مواقيت/قبلة)، قائمة التطبيقات المقفولة، سجل الصلوات، الإعدادات.
- الشبكة: طلبات تحميل صوت القرآن/قائمة القراء من mp3quran.net (يتلقى عنوان IP وطلب الملف).
- قائمة Data Safety: Location (approximate/precise) — تُجمع على الجهاز ولا تُشارك ولا تُرسل؛ لا حسابات؛ لا بيانات مالية؛ لا إعلانات. **راجع الإجابات بنفسك قبل الإرسال.** لو لا ترسل الموقع خارج الجهاز تُصرّح "لا يُجمع/لا يُشارك" حسب تعريف Google للجمع (نقل خارج الجهاز).
- **رابط سياسة الخصوصية:** لم يُخترع. أنشئ صفحة حقيقية وضع رابطها في Play Console (App content → Privacy policy)، ويفضّل إضافة رابط داخل شاشة «حول».
- تم ضبط `allowBackup=false`.

## 5) إعدادات البناء
- namespace/applicationId: `com.salli.salli_app` (لم يُغيَّر). minSdk 23. targetSdk/compileSdk من Flutter (`flutter.targetSdkVersion`) — **تحقق من الـ merged manifest بعد البناء أنه 35 أو أعلى وفق مطلب Play وقت الرفع**.
- versionName 1.0.0 من pubspec. versionCode صار يُمرَّر من Codemagic: `--build-number=$BUILD_NUMBER` (لازم يزيد في كل رفع).
- AGP 8.11.1 / Gradle 8.14.1 / Kotlin 2.2.20 / Java 17 — كما هي. لا minify/R8 مفعّل.
- إصلاح ذاكرة البناء: Jetifier معطّل، وذاكرة Gradle 5GB.

## 6) التوقيع
- لم يعد البناء يسقط على مفتاح debug بصمت؛ لو `key.properties` غير موجود يفشل بناء Release برسالة واضحة.
- `.gitignore` يمنع رفع `key.properties` و`*.jks`.
- لم أُنشئ أي مفتاح جديد. **لازم تتأكد أن `salli-release-key.jks` هو نفس مفتاح الرفع المسجل في Play Console (أو مفتاح تطبيق جديد لم يُنشر بعد).** لو فُقد مفتاح تطبيق منشور فالحل الوحيد طلب Upload Key Reset من Google.
- الـ zip المرفق **لا يحتوي** على `key.properties` ولا `.jks`: أبقِ نسختك المحلية منهما، أو اضبط متغيرات Codemagic: CM_KEYSTORE_PATH, CM_KEYSTORE_PASSWORD, CM_KEY_ALIAS, CM_KEY_PASSWORD.

## 7) تعليمات البناء
1. `flutter pub get`
2. تأكد من وجود `android/key.properties` والـ keystore.
3. `flutter build appbundle --release --build-number=<رقم أكبر من آخر رفع>`
4. الناتج: `build/app/outputs/bundle/release/app-release.aab`
5. تحقق: `bundletool` أو Play Console (Pre-launch report)، وافحص `AndroidManifest` المدمج.

## 8) إجراءات يدوية متبقية
- بناء الـ AAB فعليًا على Codemagic واختباره على جهاز (أذان، تنبيه قبل الأذان، القفل، الريستارت، Android 13–16).
- تصريحات Play Console: Accessibility API، Full-screen intent، Exact alarms، Data Safety، Content rating، Target audience (ليس للأطفال)، سياسة الخصوصية، وتعليمات وصول للمراجِع (شرح تفعيل Accessibility والأذونات + فيديو).
- التأكد من هوية مفتاح التوقيع، وتقرير `flutter analyze` و`flutter test`.
