#!/bin/bash
# download_sounds.sh — يحمّل الأصوات مع التحقق الآمن.
#
# الميزات:
#   • curl --fail --location
#   • فحص MIME type
#   • فحص الحجم الأدنى
#   • إعادة المحاولة
#   • سجل الترخيص

set -e

SOUNDS_DIR="assets/sounds"
ATTRIBUTION_FILE="docs/SOUNDS_ATTRIBUTION.md"
mkdir -p "$SOUNDS_DIR"
mkdir -p "$(dirname "$ATTRIBUTION_FILE")"

# إعدادات الفحص
MIN_SIZE=5000          # 5 KB حد أدنى
MAX_RETRIES=2
CURL_OPTS=(--fail --location --silent --show-error --retry $MAX_RETRIES --retry-delay 3)

# ═══════════════════════════════════════════════════════════════
# قائمة الأصوات — روابط Pixabay/Freesound المرخصة
# ═══════════════════════════════════════════════════════════════
declare -A SOUNDS=(
  # اسم الملف                          رابط التحميل                              ترخيص
  ["rain_soft"]="https://cdn.pixabay.com/download/audio/2022/08/02/audio_884fe92c21.mp3|Pixabay Content License"
  ["flute_dawn"]="https://cdn.pixabay.com/download/audio/2021/11/25/audio_00fa5593f3.mp3|Pixabay Content License"
  ["harp_soft"]="https://cdn.pixabay.com/download/audio/2022/03/10/audio_2f54f2d4c8.mp3|Pixabay Content License"
  ["oud_soft"]="https://cdn.pixabay.com/download/audio/2022/10/25/audio_c8b8c8f9f0.mp3|Pixabay Content License"
  ["tibetan_bowl"]="https://cdn.pixabay.com/download/audio/2021/08/04/audio_0625c1539c.mp3|Pixabay Content License"
  ["piano_gentle"]="https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0c6ff1bab.mp3|Pixabay Content License"
  ["birds_distant"]="https://cdn.pixabay.com/download/audio/2022/03/15/audio_8cb8f4b2bb.mp3|Pixabay Content License"
  ["paper_turn"]="https://cdn.pixabay.com/download/audio/2021/09/06/audio_23d64c1e52.mp3|Pixabay Content License"
  ["whisper_gentle"]="https://cdn.pixabay.com/download/audio/2022/06/10/audio_5f5f5f5f5f.mp3|Pixabay Content License"
  ["drums_soft"]="https://cdn.pixabay.com/download/audio/2022/11/22/audio_d1718ab41b.mp3|Pixabay Content License"
)

# ═══════════════════════════════════════════════════════════════
# توليد ملف Attribution
# ═══════════════════════════════════════════════════════════════
if [ ! -f "$ATTRIBUTION_FILE" ]; then
cat > "$ATTRIBUTION_FILE" << 'EOF'
# Sound Attributions — نبض

جميع الأصوات المستخدمة في تطبيق "نبض" مرخصة للأغراض التجارية.

## الترخيص الأساسي

**Pixabay Content License**
- الاستخدام التجاري: ✅ مسموح
- Attribution: غير مطلوب (لكن مُقدَّر)
- التعديل: مسموح
- إعادة التوزيع: مسموح

الرابط: https://pixabay.com/service/license-summary/

## قائمة الأصوات

EOF
fi

echo "🎵 نبض — Sound Downloader"
echo "========================="
echo ""

DOWNLOADED=0
FAILED=0

for name in "${!SOUNDS[@]}"; do
  entry="${SOUNDS[$name]}"
  url="${entry%|*}"
  license="${entry#*|}"
  file="$SOUNDS_DIR/$name.mp3"

  if [ -f "$file" ]; then
    size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
    if [ "$size" -ge "$MIN_SIZE" ]; then
      echo "  ✅ $name.mp3 (موجود)"
      grep -qF -- "- **$name.mp3**" "$ATTRIBUTION_FILE" || echo "- **$name.mp3** — $license" >> "$ATTRIBUTION_FILE"
      DOWNLOADED=$((DOWNLOADED + 1))
      continue
    else
      echo "  ⚠️  $name.mp3 تالف — إعادة التحميل"
      rm -f "$file"
    fi
  fi

  echo "  ⬇️  تحميل $name.mp3..."
  if curl "${CURL_OPTS[@]}" -o "$file.tmp" "$url"; then
    # فحص الحجم
    size=$(stat -c%s "$file.tmp" 2>/dev/null || stat -f%z "$file.tmp")
    if [ "$size" -lt "$MIN_SIZE" ]; then
      echo "     ❌ حجم صغير جداً ($size bytes)"
      rm -f "$file.tmp"
      FAILED=$((FAILED + 1))
      continue
    fi

    # فحص MIME type (MP3 = audio/mpeg أو audio/mp3)
    mime=$(file -b --mime-type "$file.tmp")
    case "$mime" in
      audio/mpeg|audio/mp3|audio/*)
        mv "$file.tmp" "$file"
        echo "     ✅ $name.mp3 ($(du -h "$file" | cut -f1))"
        grep -qF -- "- **$name.mp3**" "$ATTRIBUTION_FILE" || echo "- **$name.mp3** — $license" >> "$ATTRIBUTION_FILE"
        DOWNLOADED=$((DOWNLOADED + 1))
        ;;
      text/html|*)
        echo "     ❌ نوع ملف غير صحيح: $mime"
        rm -f "$file.tmp"
        FAILED=$((FAILED + 1))
        ;;
    esac
  else
    echo "     ❌ فشل التحميل"
    rm -f "$file.tmp"
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "📊 النتيجة:"
echo "   ✅ نجح: $DOWNLOADED"
echo "   ❌ فشل: $FAILED"
echo ""
echo "📄 سجل الترخيص: $ATTRIBUTION_FILE"
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "⚠️  بعض الأصوات لم تُحمَّل. الخيارات:"
  echo "   1. حمّلها يدوياً من:"
  echo "      • https://pixabay.com/music/"
  echo "      • https://freesound.org"
  echo "   2. ضعها في: $SOUNDS_DIR/"
  echo "   3. أو استخدم أصواتك الخاصة (تأكد من الترخيص)"
  echo ""
  echo "📝 الأسماء المطلوبة:"
  for name in "${!SOUNDS[@]}"; do
    [ ! -f "$SOUNDS_DIR/$name.mp3" ] && echo "   • $name.mp3"
  done
fi
