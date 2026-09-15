# خارطة طريق نبض — Nabd

**آخر تحديث:** 2026-09-15 بعد تحويل SVG إلى PNG
**الفرع:** `main`

## الحالة الحالية

تم تطبيق حزمة إصلاحات v2 ورفعها إلى GitHub. تم تشغيل `scripts/convert_svg_to_png.sh` بنجاح بعد تثبيت `svgexport`، وتم إنتاج ملفات PNG للأيقونات وSplash ومواد المتجر. تم تشغيل `scripts/setup_assets.sh`؛ اكتملت مرحلة تحويل SVG، ثم توقفت عند `flutter pub get` لأن Flutter غير مثبت في البيئة الحالية.

| الأولوية | البند | الحالة | ما بقي |
|---|---|---|---|
| P0 | AES-256-GCM للمحتوى والنسخ | ✅ مطبق نصيًا | اختبار runtime وفشل MAC وتدوير المفتاح |
| P0 | تبعيات الأمان والدفع والإعلانات | ✅ مدرجة | `flutter pub get` والتحقق من توافق الإصدارات |
| P0 | تحقيق الدخل | ✅ مضاف مبدئيًا | إنشاء المنتجات والتحقق من الإيصالات على المتجر |
| P1 | الإعلانات المكافأة | ✅ مضاف مبدئيًا | App ID وAd Unit IDs للإنتاج وسياسات الخصوصية |
| P1 | شاشة Paywall | ✅ مضافة ومربوطة | اختبار purchase/restore على جهاز فعلي |
| P1 | الترجمة | ✅ إعداد موجود | تشغيل `flutter gen-l10n` ومراجعة RTL والمفاتيح |
| P1 | تحويل الأصول SVG → PNG | ✅ مكتمل | تمت إضافة 12 ملف PNG، مع التحقق من وجودها وأحجامها |
| P1 | الأصوات | ⏳ متبقٍ | تنزيل 10 ملفات MP3 والتحقق من الترخيص |
| P2 | توليد أيقونات Flutter وSplash | ⏳ متوقف بيئيًا | يحتاج Flutter لتشغيل `flutter_launcher_icons` و`flutter_native_splash` |
| P2 | MODIFY checklist | ✅ موجودة | مراجعة البنود على تشغيل فعلي |
| P2 | تقارير v1/v2 | ✅ موجودة | تحديث العد النهائي عند الحاجة |
| P2 | تشغيل Flutter والتحقق | ⏳ متبقٍ | Flutter/Dart غير مثبتين |
| P2 | Android/iOS scaffolding | ⏳ متبقٍ | استكمال الملفات وبناء debug |

## الأصول الناتجة

تم توليد الأصول التالية: `app_icon.png`، `app_icon_fg.png`، `ic_launcher_foreground.png`، `splash.png`، `feature_graphic.png`، `app_icon_playstore.png`، وست صور متجر داخل `assets/store/output/`. أداة `identify` غير مثبتة، لذلك تم التحقق من وجود الملفات وأحجامها عبر `find`; سجل السكربت يؤكد الأبعاد المطلوبة.

## النواقص الحالية

الأصوات الفعلية غير موجودة في `assets/sounds/`. يمكن تشغيل `bash scripts/download_sounds.sh`، لكن يجب مراجعة الروابط والتراخيص قبل اعتمادها. كما أن خطوة توليد ملفات المنصة لم تكتمل بسبب غياب Flutter.

معرفات AdMob الإنتاجية وApp IDs ليست ضمن الأصول ولا يمكن توليدها محليًا؛ يجب إضافتها من حساب AdMob بعد إنشاء التطبيق والوحدات الإعلانية.

## الخطوات التالية

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
bash scripts/download_sounds.sh
flutter build apk --debug
```
