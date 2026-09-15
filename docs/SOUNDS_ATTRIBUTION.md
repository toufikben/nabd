# Sound Attributions — نبض

تم تنزيل ملفات الأصوات الموجودة حاليًا عبر مصادر مباشرة محددة في `scripts/download_sounds.sh`. يجب مراجعة شروط الترخيص لكل رابط قبل إصدار تجاري نهائي، والاحتفاظ بهذا السجل داخل المستودع.

## مصادر وترخيص

| الملف | المصدر المستخدم | الترخيص المعلن | الحجم الحالي |
| :--- | :--- | :--- | :--- |
| `rain_soft.mp3` | Pixabay URL سابق في السكربت | Pixabay Content License — تحقق قبل الإصدار | 5.8 MB |
| `flute_dawn.mp3` | Mixkit | Free License — تحقق من صفحة المصدر | 632 KB |
| `harp_soft.mp3` | Mixkit | Free License — تحقق من صفحة المصدر | 632 KB |
| `oud_soft.mp3` | Mixkit | Free License — تحقق من صفحة المصدر | 2.0 MB |
| `tibetan_bowl.mp3` | Pixabay URL سابق في السكربت | Pixabay Content License — تحقق قبل الإصدار | 68 KB |
| `piano_gentle.mp3` | Mixkit | Free License — تحقق من صفحة المصدر | 212 KB |
| `birds_distant.mp3` | Mixkit | Free License — تحقق من صفحة المصدر | 28 KB |
| `paper_turn.mp3` | Mixkit | Free License — تحقق من صفحة المصدر | 56 KB |
| `whisper_gentle.mp3` | Mixkit | Free License — تحقق من صفحة المصدر | 2.5 MB |
| `drums_soft.mp3` | Mixkit | Free License — تحقق من صفحة المصدر | 256 KB |

## روابط Mixkit المستخدمة

- <https://mixkit.co/free-sound-effects/> — دليل المصدر العام.
- الروابط المباشرة وأرقام الملفات محفوظة في `scripts/download_sounds.sh`.

## ملاحظات الامتثال

تم فحص الملفات من حيث الحجم ونوع MIME أثناء التنزيل. لا يكفي نجاح التنزيل لإثبات الترخيص؛ يجب الاحتفاظ برابط صفحة المصدر وتاريخ المراجعة قبل النشر. عند استخدام Freesound يجب التحقق من نوع الترخيص؛ CC-BY يتطلب Attribution، وCC-BY-NC غير صالح للاستخدام التجاري.

## استبدال الأصوات

اختر ملفًا من مصدر مرخص، ضعه في `assets/sounds/` بالاسم المطلوب، حدّث هذا السجل بالحجم والرابط والترخيص، ثم شغّل `bash scripts/download_sounds.sh` للتحقق.
