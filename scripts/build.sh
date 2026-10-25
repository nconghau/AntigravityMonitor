#!/usr/bin/env bash
# ==============================================================================
# 🎮 Antigravity Monitor — Unified Production Build & Sync Script
# Follows the Mandatory Quality Gate Protocol:
# 1. Compiles Universal Binary (arm64 + x86_64)
# 2. Bundles Resources with AppIcon.icns directly in Contents/Resources/
# 3. Ad-hoc Codesigns and verifies bundle integrity
# 4. Syncs to /Applications and refreshes LaunchServices cache
# 5. Packages Universal DMG (with Volume Icon & /Applications link) and ZIP in dist/
# 6. Restarts running app to verify live execution
# ==============================================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/VERSION"
VERSION="$(tr -d '[:space:]' < "$VERSION_FILE" 2>/dev/null || echo "2.0.0")"

BUILD_DIR="$PROJECT_ROOT/build"
DIST_DIR="$PROJECT_ROOT/dist"
APP_BUNDLE="$DIST_DIR/AntigravityMonitor.app"
APPLICATIONS_APP="/Applications/AntigravityMonitor.app"

echo "=========================================================="
echo "🎮 Antigravity Monitor — Production Build v${VERSION}"
echo "=========================================================="

mkdir -p "$BUILD_DIR" "$DIST_DIR" "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

# 1. Compile Universal Fat Binary (Apple Silicon + Intel)
echo "🔨 [1/6] Compiling Swift Universal Binaries (macOS 12.0+)..."
swiftc -parse-as-library -target arm64-apple-macos12.0 -O \
  -o "$BUILD_DIR/AntigravityMonitor_arm64" "$PROJECT_ROOT/AntigravityMonitor.swift"

swiftc -parse-as-library -target x86_64-apple-macos12.0 -O \
  -o "$BUILD_DIR/AntigravityMonitor_x86_64" "$PROJECT_ROOT/AntigravityMonitor.swift"

lipo -create \
  -output "$APP_BUNDLE/Contents/MacOS/AntigravityMonitor" \
  "$BUILD_DIR/AntigravityMonitor_arm64" \
  "$BUILD_DIR/AntigravityMonitor_x86_64"

# 2. Bundle App Metadata & Assets (MANDATORY: AppIcon.icns must be in Resources/)
echo "📦 [2/6] Packaging Bundle Resources & App Icons..."
cp "$PROJECT_ROOT/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP_BUNDLE/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$APP_BUNDLE/Contents/Info.plist" 2>/dev/null || true

cp "$PROJECT_ROOT/app.html" "$APP_BUNDLE/Contents/Resources/app.html"
rm -rf "$APP_BUNDLE/Contents/Resources/assets"
cp -R "$PROJECT_ROOT/assets" "$APP_BUNDLE/Contents/Resources/assets"

# CRITICAL RULE: AppIcon.icns MUST be directly in Contents/Resources/ for macOS Finder/Dock
cp "$PROJECT_ROOT/assets/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

# 3. Codesign & Strict Verification
echo "🔐 [3/6] Codesigning Universal App Bundle..."
codesign --force --deep -s - "$APP_BUNDLE" >/dev/null
codesign --verify --deep --strict "$APP_BUNDLE"
echo "✅ Codesign verification passed!"

# 4. Sync to /Applications & Refresh LaunchServices Icon Cache
echo "💻 [4/6] Installing to /Applications & Updating LaunchServices Cache..."
rm -rf "$APPLICATIONS_APP"
cp -R "$APP_BUNDLE" "$APPLICATIONS_APP"
touch "$APPLICATIONS_APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APPLICATIONS_APP" 2>/dev/null || true

# 5. Create Distribution DMG & ZIP
echo "💿 [5/6] Generating Universal DMG & ZIP in dist/..."
DMG_STAGE="$(mktemp -d "${TMPDIR:-/tmp}/antigravity-dmg-stage.XXXXXX")"
cp -R "$APP_BUNDLE" "$DMG_STAGE/AntigravityMonitor.app"
ln -s /Applications "$DMG_STAGE/Applications"
cp "$PROJECT_ROOT/assets/AppIcon.icns" "$DMG_STAGE/.VolumeIcon.icns"
SetFile -c icnC "$DMG_STAGE/.VolumeIcon.icns" 2>/dev/null || true
SetFile -a C "$DMG_STAGE" 2>/dev/null || true

rm -f "$DIST_DIR/AntigravityMonitor-macOS-Universal.dmg" "$DIST_DIR/AntigravityMonitor-macOS-Universal.zip"
hdiutil create -volname "AntigravityMonitor" -srcfolder "$DMG_STAGE" -ov -format UDZO "$DIST_DIR/AntigravityMonitor-macOS-Universal.dmg" >/dev/null
rm -rf "$DMG_STAGE"

(cd "$DIST_DIR" && zip -qry "AntigravityMonitor-macOS-Universal.zip" "AntigravityMonitor.app")
echo "✅ DMG & ZIP created in dist/:"
ls -lh "$DIST_DIR"/*.dmg "$DIST_DIR"/*.zip

# 6. Restart App & Live Check
echo "🚀 [6/6] Restarting /Applications/AntigravityMonitor.app..."
pkill -f AntigravityMonitor || true
sleep 1
open "$APPLICATIONS_APP"

sleep 1
if pgrep -lf AntigravityMonitor >/dev/null; then
  PID=$(pgrep -f "/Applications/AntigravityMonitor.app/Contents/MacOS/AntigravityMonitor" | head -n 1)
  echo "✅ AntigravityMonitor is running with PID: ${PID}"
else
  echo "⚠️ App did not start automatically. Check permissions."
fi

echo "=========================================================="
echo "🎉 BUILD HOÀN TẤT ĐÚNG QUY TRÌNH!"
echo "👉 App:          $APPLICATIONS_APP"
echo "👉 DMG:          $DIST_DIR/AntigravityMonitor-macOS-Universal.dmg"
echo "👉 ZIP:          $DIST_DIR/AntigravityMonitor-macOS-Universal.zip"
echo "=========================================================="
