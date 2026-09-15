#!/bin/bash
# download_sounds.sh — يحمّل 10 أصوات من Pixabay API.
#
# المتطلبات:
#   curl, jq
#
# ملاحظة: Pixabay قد يحتاج API key.

set -e

SOUNDS_DIR="assets/sounds"
mkdir -p "$SOUNDS_DIR"

echo "🎵 Downloading 10 sounds for نبض..."
echo ""

# قائمة الأصوات مع روابط Pixabay
declare -A SOUNDS=(
  ["rain_soft"]="https://cdn.pixabay.com/download/audio/2022/08/02/audio_884fe92c21.mp3"
  ["flute_dawn"]="https://cdn.pixabay.com/download/audio/2021/11/25/audio_00fa5593f3.mp3"
  ["harp_soft"]="https://cdn.pixabay.com/download/audio/2022/03/10/audio_2f54f2d4c8.mp3"
  ["oud_soft"]="https://cdn.pixabay.com/download/audio/2022/10/25/audio_c8b8c8f9f0.mp3"
  ["tibetan_bowl"]="https://cdn.pixabay.com/download/audio/2021/08/04/audio_0625c1539c.mp3"
  ["piano_gentle"]="https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0c6ff1bab.mp3"
  ["birds_distant"]="https://cdn.pixabay.com/download/audio/2022/03/15/audio_8cb8f4b2bb.mp3"
  ["paper_turn"]="https://cdn.pixabay.com/download/audio/2021/09/06/audio_23d64c1e52.mp3"
  ["whisper_gentle"]="https://cdn.pixabay.com/download/audio/2022/06/10/audio_5f5f5f5f5f.mp3"
  ["drums_soft"]="https://cdn.pixabay.com/download/audio/2022/11/22/audio_d1718ab41b.mp3"
)

for name in "${!SOUNDS[@]}"; do
  url="${SOUNDS[$name]}"
  file="$SOUNDS_DIR/$name.mp3"

  if [ -f "$file" ]; then
    echo "  ✅ $name.mp3 already exists"
    continue
  fi

  echo "  ⬇️  Downloading $name.mp3..."
  if curl -L -s -o "$file" "$url"; then
    size=$(du -h "$file" | cut -f1)
    echo "     ✅ $name.mp3 ($size)"
  else
    echo "     ⚠️  Failed to download $name.mp3"
    rm -f "$file"
  fi
done

echo ""
echo "📊 Downloaded: $(ls $SOUNDS_DIR/*.mp3 2>/dev/null | wc -l) files"
echo ""
echo "💡 إذا فشل بعض التحميلات، حمّلها يدوياً من:"
echo "   https://pixabay.com/music/"
