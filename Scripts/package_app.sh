#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/Silica.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

cd "$ROOT"
swift build -c release

rm -rf "$APP"
mkdir -p "$MACOS" "$RESOURCES"
cp ".build/release/Silica" "$MACOS/Silica"
cp "Release/Info.plist" "$CONTENTS/Info.plist"
cp -R "Silica/Resources/Assets.xcassets" "$RESOURCES/Assets.xcassets"

ICONSET="$ROOT/build/AppIcon.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_16x16.png" "$ICONSET/icon_16x16.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32.png" "$ICONSET/icon_16x16@2x.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32.png" "$ICONSET/icon_32x32.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_64x64.png" "$ICONSET/icon_32x32@2x.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" "$ICONSET/icon_128x128.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" "$ICONSET/icon_128x128@2x.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" "$ICONSET/icon_256x256.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" "$ICONSET/icon_256x256@2x.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" "$ICONSET/icon_512x512.png"
cp "Silica/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png" "$ICONSET/icon_512x512@2x.png"
iconutil -c icns "$ICONSET" -o "$RESOURCES/AppIcon.icns"

echo "Created $APP"
echo "For distribution, sign with Developer ID and notarize:"
echo "codesign --force --options runtime --entitlements Release/Silica.entitlements --sign \"Developer ID Application: TEAM\" \"$APP\""
echo "xcrun notarytool submit \"$APP\" --keychain-profile PROFILE --wait"
