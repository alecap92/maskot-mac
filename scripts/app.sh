#!/bin/bash
# Compila en release y arma Maskot.app (sin Xcode). Uso: ./scripts/app.sh
set -euo pipefail
cd "$(dirname "$0")/.."

swift build -c release --product Maskot
BIN=$(swift build -c release --show-bin-path)
APP="build/Maskot.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/es.lproj"
cp "$BIN/Maskot" "$APP/Contents/MacOS/Maskot"
touch "$APP/Contents/Resources/es.lproj/Localizable.strings"

# LSUIElement: vive solo en la barra de menú (🧢), sin ícono en el Dock.
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleDevelopmentRegion</key><string>es</string>
  <key>CFBundleLocalizations</key><array><string>es</string></array>
  <key>CFBundleName</key><string>Maskot</string>
  <key>CFBundleDisplayName</key><string>Maskot</string>
  <key>CFBundleIdentifier</key><string>io.maskot.mac</string>
  <key>CFBundleExecutable</key><string>Maskot</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>0.1</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

codesign --force --deep --sign - "$APP" 2>/dev/null || true
echo "✅ $APP listo"
open "$APP"
