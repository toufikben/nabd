#!/bin/bash
# setup_assets.sh — يهيئ كل الأصول (PNG + Sounds).
#
# المتطلبات:
#   npm install -g svgexport  (لتحويل SVG)
#   pip install requests  (لتحميل الأصوات)

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🎨 نبض — Asset Setup"
echo "===================="
echo ""

# ═══════════════════════════════════════════════════════════════
# 1. إنشاء المجلدات
# ═══════════════════════════════════════════════════════════════
echo "📁 Creating directories..."
mkdir -p assets/icons
mkdir -p assets/sounds
mkdir -p assets/store/screenshots
mkdir -p assets/store/output
mkdir -p assets/social

# ═══════════════════════════════════════════════════════════════
# 2. تحويل SVGs إلى PNGs
# ═══════════════════════════════════════════════════════════════
if command -v svgexport &> /dev/null; then
  echo "🎨 Converting SVG to PNG..."

  # App Icon
  if [ -f assets/icons/app_icon.svg ]; then
    echo "  → app_icon.png (1024×1024)"
    svgexport assets/icons/app_icon.svg assets/icons/app_icon.png 1024:1024
  fi

  # App Icon Foreground
  if [ -f assets/icons/app_icon_fg.svg ]; then
    echo "  → app_icon_fg.png (1024×1024)"
    svgexport assets/icons/app_icon_fg.svg assets/icons/app_icon_fg.png 1024:1024
  fi

  # Splash
  if [ -f assets/icons/splash_logo.svg ]; then
    echo "  → splash.png (800×800)"
    svgexport assets/icons/splash_logo.svg assets/icons/splash.png 800:800
  fi

  # Feature Graphic
  if [ -f assets/store/feature_graphic.svg ]; then
    echo "  → feature_graphic.png (1024×500)"
    svgexport assets/store/feature_graphic.svg assets/store/feature_graphic.png 1024:500
  fi

  # Play Store Icon
  if [ -f assets/icons/app_icon.svg ]; then
    echo "  → app_icon_playstore.png (512×512)"
    svgexport assets/icons/app_icon.svg assets/store/app_icon_playstore.png 512:512
  fi

  # Store Screenshots
  if [ -d assets/store/screenshots ]; then
    for svg in assets/store/screenshots/*.svg; do
      [ -f "$svg" ] || continue
      filename=$(basename "$svg" .svg)
      echo "  → screenshots/$filename.png"
      svgexport "$svg" "assets/store/output/$filename.png" 1080:1920
    done
  fi

  echo "  ✅ SVG conversion complete"
else
  echo "⚠️  svgexport not found. Install with:"
  echo "    npm install -g svgexport"
  echo ""
  echo "    أو استخدم أداة بديلة مثل:"
  echo "    - Inkscape: inkscape --export-type=png --export-width=1024 file.svg"
  echo "    - ImageMagick: convert -background none file.svg -resize 1024x1024 file.png"
fi

# ═══════════════════════════════════════════════════════════════
# 3. تحميل الأصوات (Freesound API أو Pixabay)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🔊 Setting up sounds..."

# قائمة الأصوات
SOUNDS=(
  "rain_soft"
  "flute_dawn"
  "harp_soft"
  "oud_soft"
  "tibetan_bowl"
  "piano_gentle"
  "birds_distant"
  "paper_turn"
  "whisper_gentle"
  "drums_soft"
)

# إذا كانت الملفات موجودة، تخطَّ
if [ -f "assets/sounds/piano_gentle.mp3" ]; then
  echo "  ✅ Sounds already exist"
else
  echo "  ⚠️  Sounds not found."
  echo ""
  echo "  📥 يُرجى تحميل الأصوات يدوياً من:"
  echo "     • https://freesound.org"
  echo "     • https://pixabay.com/music/"
  echo "     • https://mixkit.co/free-sound-effects/"
  echo ""
  echo "  📁 ضعها في: assets/sounds/ بالأسماء التالية:"
  for sound in "${SOUNDS[@]}"; do
    echo "     • $sound.mp3"
  done
  echo ""
  echo "  💡 يمكنك استخدام script آخر لتحميلها من Pixabay API:"
  echo "     bash scripts/download_sounds.sh"
fi

# ═══════════════════════════════════════════════════════════════
# 4. توليد الأيقونات و Splash
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🎨 Generating app icons and splash..."

if [ -f "assets/icons/app_icon.png" ]; then
  flutter pub get
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  echo "  ✅ Icons and splash generated"
else
  echo "  ⚠️  app_icon.png not found. Run SVG conversion first."
fi

# ═══════════════════════════════════════════════════════════════
# 5. التحقق النهائي
# ═══════════════════════════════════════════════════════════════
echo ""
echo "✅ Asset setup complete!"
echo ""
echo "📊 Summary:"
echo "   Icons:       $(ls assets/icons/*.png 2>/dev/null | wc -l) files"
echo "   Sounds:      $(ls assets/sounds/*.mp3 2>/dev/null | wc -l) files"
echo "   Screenshots: $(ls assets/store/output/*.png 2>/dev/null | wc -l) files"
echo ""
echo "📁 Next steps:"
echo "   1. flutter pub get"
echo "   2. flutter gen-l10n"
echo "   3. flutter analyze"
echo "   4. flutter test"
echo "   5. flutter build appbundle --release"
