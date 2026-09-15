# خارطة طريق نبض — Nabd

**آخر تحديث:** 2026-09-15 بعد حزمة v4 وworkflow Android
**الفرع:** `main`

## الحالة الحالية

تمت إضافة workflow GitHub Actions للبناء التلقائي، وموارد Android المفقودة، وfallback للصوت، ومصادر صوت بديلة. تم تنزيل الأصوات العشرة بنجاح وفحصها من حيث الحجم وMIME. لم يُشغّل Flutter محليًا لأن SDK غير مثبت، وسيكون التحقق الفعلي داخل GitHub Actions بعد الرفع.

| الأولوية | البند | الحالة | ما بقي |
|---|---|---|---|
| P0 | AES-256-GCM للمحتوى والنسخ | ✅ مطبق نصيًا | تشغيل الاختبارات داخل workflow |
| P0 | AdMobConfig ومعرفات Rewarded | ✅ مضاف | IDs الإنتاجية وApp IDs الحقيقية من حساب AdMob |
| P0 | Android Manifest وموارد XML | ✅ أضيفت | تحقق build الفعلي وMainActivity/Gradle عبر bootstrap |
| P1 | خدمة الإعلانات المحسنة | ✅ مطبقة | اختبار جهاز حقيقي وسياسات الخصوصية |
| P1 | تنزيل الأصوات الآمن | ✅ مكتمل | مراجعة الترخيص النهائي لكل رابط |
| P1 | سجل تراخيص الأصوات | ✅ محدث | تحديثه إذا تغير أي مصدر |
| P1 | تحويل الأصول SVG → PNG | ✅ مكتمل ومتحقق | 12 PNG صحيحة الأبعاد |
| P1 | اختبار التشفير | ✅ أضيف | تشغيل `flutter test` داخل Actions |
| P2 | Fallback صوت Splash | ✅ أضيف | اختبار التشغيل على Android |
| P2 | workflow Debug APK/AAB | ✅ أضيف | انتظار أول تشغيل GitHub Actions |
| P2 | Release APK/AAB موقّع | ⏳ متبقٍ | مفاتيح keystore وSecrets وإعداد App ID الإنتاجي |
| P2 | iOS scaffold | ⏳ متبقٍ | Podfile وRunner project وentitlements |

## نتائج الأصول

تم توليد الأيقونات وSplash وFeature Graphic ولقطات المتجر بالأبعاد المطلوبة. أصبحت ملفات `assets/sounds/` العشرة موجودة: `rain_soft`, `flute_dawn`, `harp_soft`, `oud_soft`, `tibetan_bowl`, `piano_gentle`, `birds_distant`, `paper_turn`, `whisper_gentle`, و`drums_soft`.

## Workflow البناء

الملف `.github/workflows/android-build.yml` يشغل التحقق والبناء عند push وPull Request وworkflow_dispatch. يبني Debug APK وDebug AAB دون أسرار ويرفعهما كـ Artifacts. لا يبني Release موقّعًا حاليًا؛ هذا مقصود لأن المستخدم لم يضف الأسرار بعد.

## النواقص المؤكدة

ما زال Android bootstrap الكامل غير متحقق محليًا بسبب غياب Flutter. إذا فشل workflow، يجب تسجيل الخطأ هنا ومعالجته قبل إضافة Release. كما أن Manifest يستخدم Test App ID، و`--dart-define` لا يبدل native XML تلقائيًا.

iOS يحتاج Podfile وRunner entitlements وملفات مشروع Xcode. الشراء والإعلانات والتشفير تحتاج اختبارات جهاز/محاكي قبل النشر.

## التحقق المنجز

فحص Bash للسكريبتات نجح، وموارد XML الجديدة أُضيفت، وfallback الصوت يستخدم فقط الأصوات الموجودة فعليًا، وسكربت المصادر البديلة نجح في تنزيل 10/10 أصوات. لم يُنفذ Dart analyzer أو Flutter tests محليًا.

## الخطوات التالية

1. راقب أول تشغيل لـ `Android Build` في GitHub Actions.
2. أصلح أي أخطاء Flutter تظهر في سجل workflow.
3. أضف Secrets التوقيع فقط عند الجاهزية لبناء Release.
4. استبدل Test App ID في Manifest بمعرف AdMob الإنتاجي عبر CI/Native configuration.
