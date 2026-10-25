# Antigravity Monitor — Build & Release Standards

> **Trigger**: Whenever building, packaging, deploying, or testing Antigravity Monitor.

---

## 🛡️ Mandatory Build Checklist

Every build MUST satisfy all 7 verification gates:

### 1. Logo & App Icon (P0)
- [ ] `Contents/Resources/AppIcon.icns` exists directly in root Resources folder.
- [ ] `Info.plist` includes `<key>CFBundleIconFile</key><string>AppIcon</string>`.
- [ ] `Info.plist` includes `<key>CFBundleIconName</key><string>AppIcon</string>`.
- [ ] `AntigravityMonitor.swift` sets `NSApp.applicationIconImage` on startup.
- [ ] Web files (`app.html`, `download.html`) have `<link rel="icon" type="image/jpeg" href="./assets/logo.jpg"/>`.

### 2. Universal Architecture
- [ ] Target architecture includes both `arm64` (Apple Silicon) and `x86_64` (Intel).
- [ ] Minimum macOS deployment target is `12.0`.
- [ ] Verified via `lipo -info <binary>`.

### 3. macOS Codesigning
- [ ] Bundle signed with ad-hoc signature: `codesign --force --deep -s - <bundle>`.
- [ ] Verified with: `codesign --verify --deep --strict <bundle>`.

### 4. Local Installation & Icon Cache
- [ ] App installed to `/Applications/AntigravityMonitor.app`.
- [ ] Timestamp touched: `touch /Applications/AntigravityMonitor.app`.
- [ ] LaunchServices cache invalidated via `lsregister -f /Applications/AntigravityMonitor.app`.
- [ ] App process running and responsive (`pgrep -lf AntigravityMonitor`).

### 5. DMG Distribution
- [ ] DMG volume contains custom volume icon (`.VolumeIcon.icns`).
- [ ] Custom icon attribute enabled on volume root via `SetFile -a C`.
- [ ] Symlink to `/Applications` included for drag-and-drop installation.
- [ ] DMG file verified with `hdiutil attach -nobrowse` and `hdiutil detach`.

### 6. Cloud Deployment
- [ ] Private live stream updated via `./deploy-personal.sh` -> `https://agy-monitor-nconghau.surge.sh`.
- [ ] Public landing page updated with latest DMG & ZIP -> `https://agy-monitor.surge.sh`.

### 7. Automated One-Command Workflow
Always use the unified build script to prevent human error:
```bash
./scripts/build.sh
```
