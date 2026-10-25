#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/VERSION"
VERSION="${1:-$(tr -d '[:space:]' < "$VERSION_FILE")}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version '$VERSION'. Use semantic versioning, e.g. 2.1.0." >&2
  exit 1
fi

RELEASE_ROOT="$PROJECT_ROOT/releases/v$VERSION"
RELEASE_APP="$RELEASE_ROOT/AntigravityMonitor.app"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/antigravity-monitor-build.XXXXXX")"
STAGE_APP="$STAGE/AntigravityMonitor.app"
trap 'rm -rf "$STAGE"' EXIT

if [[ -e "$RELEASE_ROOT" && "${FORCE:-0}" != "1" ]]; then
  echo "Release v$VERSION already exists: $RELEASE_ROOT" >&2
  echo "To overwrite, run with FORCE=1 $0 $VERSION" >&2
  exit 1
elif [[ -e "$RELEASE_ROOT" && "${FORCE:-0}" == "1" ]]; then
  echo "Overwriting existing release v$VERSION..."
  rm -rf "$RELEASE_ROOT"
fi

mkdir -p "$PROJECT_ROOT/build" "$STAGE_APP/Contents/MacOS" "$STAGE_APP/Contents/Resources"

echo "Building AntigravityMonitor v$VERSION (arm64)..."
swiftc -parse-as-library -target arm64-apple-macos12.0 -O \
  -o "$PROJECT_ROOT/build/AntigravityMonitor_arm64" "$PROJECT_ROOT/AntigravityMonitor.swift"

echo "Building AntigravityMonitor v$VERSION (x86_64)..."
swiftc -parse-as-library -target x86_64-apple-macos12.0 -O \
  -o "$PROJECT_ROOT/build/AntigravityMonitor_x86_64" "$PROJECT_ROOT/AntigravityMonitor.swift"

lipo -create \
  -output "$STAGE_APP/Contents/MacOS/AntigravityMonitor" \
  "$PROJECT_ROOT/build/AntigravityMonitor_arm64" \
  "$PROJECT_ROOT/build/AntigravityMonitor_x86_64"

cp "$PROJECT_ROOT/Info.plist" "$STAGE_APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$STAGE_APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$STAGE_APP/Contents/Info.plist"
cp "$PROJECT_ROOT/app.html" "$STAGE_APP/Contents/Resources/app.html"
cp -R "$PROJECT_ROOT/assets" "$STAGE_APP/Contents/Resources/assets"

# CRITICAL: App icon MUST be in Contents/Resources/AppIcon.icns for macOS Finder/Dock
cp "$PROJECT_ROOT/assets/AppIcon.icns" "$STAGE_APP/Contents/Resources/AppIcon.icns"

codesign --force --deep -s - "$STAGE_APP" >/dev/null
codesign --verify --deep --strict "$STAGE_APP"

mkdir -p "$RELEASE_ROOT"
ditto "$STAGE_APP" "$RELEASE_APP"
(cd "$RELEASE_ROOT" && zip -qry "AntigravityMonitor-v$VERSION-macOS-Universal.zip" "AntigravityMonitor.app")

# Build DMG with custom volume icon and Applications symlink
echo "Creating DMG image for v$VERSION..."
DMG_STAGE="$(mktemp -d "${TMPDIR:-/tmp}/antigravity-dmg-stage.XXXXXX")"
cp -R "$RELEASE_APP" "$DMG_STAGE/AntigravityMonitor.app"
ln -s /Applications "$DMG_STAGE/Applications"
cp "$PROJECT_ROOT/assets/AppIcon.icns" "$DMG_STAGE/.VolumeIcon.icns"
SetFile -c icnC "$DMG_STAGE/.VolumeIcon.icns" 2>/dev/null || true
SetFile -a C "$DMG_STAGE" 2>/dev/null || true

hdiutil create -volname "AntigravityMonitor" -srcfolder "$DMG_STAGE" -ov -format UDZO "$RELEASE_ROOT/AntigravityMonitor-v$VERSION-macOS-Universal.dmg"
rm -rf "$DMG_STAGE"

cat > "$RELEASE_ROOT/build-info.txt" <<EOF
Product: AntigravityMonitor
Version: $VERSION
Architectures: arm64 x86_64
Source: $PROJECT_ROOT
Built: $(date '+%Y-%m-%d %H:%M:%S %z')
Signature: ad-hoc
EOF

echo
echo "Built: $RELEASE_APP"
echo "Archive: $RELEASE_ROOT/AntigravityMonitor-v$VERSION-macOS-Universal.zip"
lipo -info "$RELEASE_APP/Contents/MacOS/AntigravityMonitor"
