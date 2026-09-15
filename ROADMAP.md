# خارطة طريق نبض — Nabd

**آخر تحديث:** 2026-09-15 بعد التحقق النهائي من حزمة v3
**الفرع:** `main`

## الحالة الحالية

تم تطبيق حزمة v3 الخاصة بـ AdMob والأصوات والاختبارات وقائمة ما قبل الإطلاق. تم تشغيل سكربت الأصول المحسّن وإصلاح خطأ أبعاد كان يعيد تمرير `1024:1024` بصيغة مكررة إلى `svgexport`. أصبحت أبعاد PNG صحيحة، وأصبحت ملفات Manifest وInfo.plist صالحة XML. لم يُشغّل Flutter لأن SDK غير مثبت.

| الأولوية | البند | الحالة | ما بقي |
|---|---|---|---|
| P0 | AES-256-GCM للمحتوى والنسخ | ✅ مطبق نصيًا | تشغيل اختبارات runtime |
| P0 | AdMobConfig ومعرفات Rewarded | ✅ مضاف | IDs الإنتاجية وApp IDs الحقيقية من حساب AdMob |
| P0 | Android Manifest وiOS Info.plist | ✅ XML صالح مع Test IDs | استبدال Test App IDs وإكمال scaffold وموارد المنصة |
| P1 | خدمة الإعلانات المحسنة | ✅ مطبقة | اختبار جهاز حقيقي وسياسات الخصوصية |
| P1 | تنزيل الأصوات الآمن | ✅ مطبق | 2/10 فقط؛ 8 روابط تعيد HTTP 403 وتحتاج مصادر بديلة |
| P1 | سجل تراخيص الأصوات | ✅ موجود ومصحح | تحديثه عند إضافة أي صوت جديد |
| P1 | تحويل الأصول SVG → PNG | ✅ مكتمل ومتحقق | 12 PNG صحيحة الأبعاد |
| P1 | اختبار التشفير | ✅ أضيف | لم يُنفذ بسبب غياب Flutter |
| P2 | قائمة ما قبل الإطلاق | ✅ أضيفت | تعليم البنود بعد تحقق فعلي |
| P2 | تهيئة Flutter Icons/Splash | ⏳ متوقف | Flutter غير مثبت |
| P2 | Android/iOS scaffold | ⏳ ناقص | موارد XML وMainActivity وGradle وPodfile/entitlements غير موجودة |

## نتائج الأصول

تم توليد `app_icon.png` (1024×1024)، `app_icon_fg.png` (1024×1024)، `ic_launcher_foreground.png` (432×432)، `splash.png` (800×800)، `app_icon_playstore.png` (512×512)، `feature_graphic.png` (1024×500)، وست صور متجر (1080×1920). تم حفظ صوتي `rain_soft.mp3` و`tibetan_bowl.mp3` فقط؛ فشلت ثمانية روابط HTTP 403.

تم إصلاح سكربت الإعداد ليولد foreground adaptive ولا يفشل كاملًا عند غياب Flutter. وتم إصلاح سكربت الأصوات ليحافظ على سجل التراخيص ولا يكرر المدخلات.

## AdMob

تمت إضافة `lib/core/admob_config.dart`، وتحويل الخدمة لاستخدام Test IDs في Debug و`--dart-define` في Release. تمت إضافة Test App IDs إلى Manifest وInfo.plist، لكن `--dart-define` لا يحقن native XML تلقائيًا؛ يجب استبدال App IDs عبر خطوة native/CI بعد توفيرها من حساب AdMob.

## النواقص المؤكدة

Manifest يشير إلى `@xml/shortcuts` و`@xml/file_paths` و`@xml/widget_journal_info`، ولا توجد هذه الملفات. كما يشير إلى `.MainActivity` وموارد Flutter القياسية غير الموجودة لأن scaffold Android ناقص. iOS يحتاج Podfile وRunner entitlements وملفات المشروع وتهيئة SKAdNetwork مكتملة.

لا يمكن اعتماد التشفير أو الشراء أو الإعلانات قبل تشغيل Flutter والاختبارات على جهاز/محاكي. يجب أيضًا استبدال Test App IDs وRewarded IDs بمعرفات حقيقية قبل الإصدار.

## التحقق المنجز

فحص XML نجح للـ Manifest وInfo.plist. فحص أبعاد PNG نجح لكل الأيقونات ولقطات المتجر. فحص Bash نجح للسكريبتين. لا يزال Dart analyzer وFlutter tests وbuild غير منفذة.

## الخطوات التالية

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --debug
```
