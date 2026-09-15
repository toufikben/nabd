# خارطة طريق نبض — Nabd

**آخر تحديث:** 2026-09-15 بعد تطبيق حزمة الإصلاحات v2
**الفرع:** `main`

## الحالة الحالية

تم استخراج بنية التطبيق من عشرة مرفقات، وحُفظت المرفقات الأصلية والـ manifest. طُبقت إصلاحات v2 للأمان والدفع والأصول والتوثيق. أُصلحت تعارضات الاستخراج المعروفة في التهيئة والألوان والراوتر. لم يُشغّل Flutter بعد لأن SDK غير متاح في بيئة التنفيذ الحالية.

| الأولوية | البند | الحالة | الدليل أو الملاحظة |
|---|---|---|---|
| P0 | AES-256-GCM للمحتوى | ✅ مطبق نصيًا | `lib/services/encryption_service.dart` يستخدم `cryptography` وSecure Storage |
| P0 | تشفير النسخ الاحتياطي | ✅ مطبق نصيًا | `lib/services/backup_service.dart` يستخدم AES-GCM وPBKDF2 |
| P0 | تبعيات الدفع والأمان | ✅ مضافة | `pubspec.yaml` يتضمن `cryptography`, `in_app_purchase`, `google_mobile_ads`, `just_audio` |
| P0 | تحقيق الدخل | ✅ مضاف مبدئيًا | `lib/services/monetization_service.dart` |
| P1 | الإعلانات المكافأة | ✅ مضاف مبدئيًا | `lib/services/rewarded_ad_service.dart`، معرفات الإنتاج ما زالت مطلوبة |
| P1 | شاشة Paywall | ✅ مضافة ومربوطة | `lib/features/billing/paywall_screen.dart` ومسار `/paywall` |
| P1 | إعداد الترجمة | ✅ مضاف | `l10n.yaml`، ويحتاج `flutter gen-l10n` |
| P1 | توليد الأصول والأصوات | ✅ سكربتات مضافة | لم تُشغّل بعد، والأصول الثنائية غير موجودة |
| P2 | مراجعة MODIFY | ✅ قائمة مراجعة مضافة | `docs/MODIFY_CHECKLIST.md` |
| P2 | تقرير v2 | ✅ مضاف | `docs/EXTRACTION_REPORT_v2.md` |
| P2 | تعارض API التشفير في main | ✅ مغلق | استبدال `generateMasterKey()` بـ `initialize()` |
| P2 | ألوان Paywall المفقودة | ✅ مغلق | إضافة `border` و`surfaceAlt` إلى `AppColors` |
| P2 | تشغيل Flutter والتحقق | ⏳ متبقٍ | Flutter/Dart غير مثبتين |
| P2 | إنشاء منتجات المتجر والإعلانات | ⏳ متبقٍ | يتطلب Play Console/App Store Connect/AdMob |

## النواقص المكتشفة فورًا

الأصول الثنائية غير موجودة بعد: `assets/icons/app_icon.png`, `assets/icons/app_icon_fg.png`, `assets/icons/splash.png`، ومجلد `assets/sounds/` فارغ. يجب تشغيل سكربت الأصول في بيئة مزودة بـ Flutter وأداة SVG، ثم مراجعة تراخيص الأصوات قبل النشر.

ملفات Android وiOS الموجودة حاليًا ليست scaffold كاملًا. لا يمكن اعتماد التوافق حتى تشغيل `flutter pub get`, `flutter analyze`, `flutter test` وبناء Android فعليًا.

التشفير أصبح AES-GCM على مستوى الكود، لكن لا يجوز إعلان الجاهزية الأمنية قبل اختبار round-trip، اختبار فشل MAC، اختبار تدوير المفتاح، وفحص النسخ الاحتياطي على جهاز فعلي.

نظام الدفع يستخدم product IDs تجريبية منطقيًا، والإعلانات تستخدم Test IDs في وضع debug وplaceholders في release؛ يلزم إعداد الحسابات والمعرفات الحقيقية قبل النشر.

## أوامر التحقق المؤجلة

```bash
flutter clean
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
bash scripts/setup_assets.sh
flutter build apk --debug
```
