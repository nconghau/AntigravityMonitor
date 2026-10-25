# AGENTS.md — Antigravity Monitor

> This file is the single source of truth for AI agents (Codex / Antigravity / Gemini) when working with this repository.
> Optimized for **100% Build Reliability, Native macOS Quality, and Zero-Regressions**.

---

## Project Identity

**Antigravity Monitor** is a native macOS MenuBar & Desktop companion application (SwiftUI + WebKit + HTML/JS/CSS Tailwind) for monitoring autonomous AI coding agents spawned by Google DeepMind Antigravity.
It visualizes agents as playful 3D chibi sprites in an isometric 4-room virtual Game Dev Studio, tracks live vibe coding sprint goals, plays relaxing Vietnamese Lo-fi tunes, and monitors cloud quota telemetry.

---

## Architecture (Read This First)

```
antigravity-menubar/
├── AntigravityMonitor.swift       → Swift entrypoint, Native Bridge (WKScriptMessageHandler), App Icon setter, Scanner
├── Info.plist                     → App bundle metadata, CFBundleIconFile / CFBundleIconName
├── app.html                       → Core App UI (Tailwind, Game Dev Studio, Sprint Tracker, Jukebox, Telemetry)
├── download.html                  → Official public landing page (feature showreel, download links, 3D gallery)
├── assets/                        → 3D Playful Chibi bots, AppIcon.icns, logo.jpg, studio furniture
├── build/                         → Temporary compiled Swift binaries (arm64 & x86_64)
├── dist/                          → Distribution packages (Universal DMG, Universal ZIP, .app)
├── releases/                      → Versioned release archives (v$VERSION)
└── scripts/                       → Automation & Build Pipeline:
    ├── build.sh                   → Single-command production build, icon verification, codesign, & install
    └── build-version.sh           → Versioned release packager (Universal fat binary, DMG, ZIP, build-info)
```

**Tech Stack**:
* **macOS Native Wrapper**: Swift 5.9+ / SwiftUI (macOS 12.0+ target), WebKit Bridge.
* **Architecture**: Universal Binary (`arm64` Apple Silicon M1-M4 + `x86_64` Intel).
* **Frontend**: Pure HTML5 / CSS3 / Vanilla JS + Tailwind CSS (Zero node_modules bloat, offline ready).
* **Audio Engine**: Synthesized 100% offline via Web Audio API (Lofi chords, mechanical typing SFX).
* **Distribution**: DMG with Custom Volume Icon + ZIP + Surge Static Hosting.

---

## ⚖️ The Constitutional Standard (100% Reliability)

1. **STRICT: App Logo & Icon Packaging Protocol (P0 Mandatory)**:
   * Every `.app` bundle MUST contain `Contents/Resources/AppIcon.icns` directly inside `Contents/Resources/`.
   * Never leave `AppIcon.icns` only in `Contents/Resources/assets/` — macOS Finder and LaunchServices will fail to load the icon and fallback to generic paper/pencil icon.
   * `Info.plist` MUST specify both:
     ```xml
     <key>CFBundleIconFile</key>
     <string>AppIcon</string>
     <key>CFBundleIconName</key>
     <string>AppIcon</string>
     ```
   * `AppDelegate.applicationDidFinishLaunching` in `AntigravityMonitor.swift` MUST programmatically set `NSApp.applicationIconImage` on startup to force Dock and App Switcher to display the 3D clay logo instantly.
   * Every DMG MUST contain root `.VolumeIcon.icns` with `SetFile -a C` and an `/Applications` symlink.
   * Both `app.html` and `download.html` MUST have `<link rel="icon" type="image/jpeg" href="./assets/logo.jpg"/>`.

2. **Universal Fat Binary Rule**:
   * NEVER build or distribute single-arch binaries. Always compile `arm64` and `x86_64`, then stitch with `lipo -create`.
   * Verify using `lipo -info <binary>`.

3. **Strict Codesign & Cache Invalidation Rule**:
   * Always codesign before distribution: `codesign --force --deep -s - <app_path>`.
   * Verify signature: `codesign --verify --deep --strict <app_path>` (0 errors).
   * After copying to `/Applications/AntigravityMonitor.app`, ALWAYS invalidate macOS LaunchServices cache:
     ```bash
     touch /Applications/AntigravityMonitor.app
     /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/AntigravityMonitor.app
     ```

4. **Playful UI & Responsive Standards**:
   * Follow the 2-Tier Header layout in `app.html`. Never cram all control pills into a single unscrollable line.
   * Sprint countdown buttons must show clean time (`17:15 (25m left)` / `17:15 (Còn 25p)`), never clip or slice task titles into ugly truncated strings like `CRM +..`. Full title lives in tooltip `title="..."`.
   * Countdown flip numbers in `sprint-flip-box` MUST maintain `line-height: 1`, `overflow: visible`, and `box-sizing: border-box` to prevent digits from ever being clipped or covered.
   * Support Bilingual EN (default) and VI seamlessly.

---

## ⚡ The One-Line Trigger

When asked to: **"Build App"**, **"Package Release"**, or **"Build đúng quy trình"** -> AI MUST run:

```bash
# 1. Run the unified production build script
./scripts/build.sh

# 2. If deploying to cloud:
./deploy-personal.sh                                         # Deploy private live stream
surge /tmp/agy_monitor_public_landing --domain agy-monitor.surge.sh # Deploy public landing + downloads
```

---

## 🛡️ Mandatory Quality Gate Sequence

Before completing ANY task involving code or UI changes, follow this EXACT sequence:

1. **Validate HTML/JS/CSS**: Verify syntax, tags, and i18n keys in `app.html` and `download.html`.
2. **Execute Build Script**: Run `./scripts/build.sh`.
   * Compiles arm64 & x86_64 universal binary.
   * Injects `AppIcon.icns` into `Contents/Resources/`.
   * Codesigns and verifies bundle.
   * Installs to `/Applications/AntigravityMonitor.app`.
   * Flushes macOS LaunchServices icon cache.
   * Generates `dist/AntigravityMonitor-macOS-Universal.dmg` & `.zip`.
   * Restarts the app and checks PID.
3. **Verify App Process**: Ensure `pgrep -lf AntigravityMonitor` reports active PID.
4. **Deploy**:
   * Private: Run `./deploy-personal.sh` -> `https://agy-monitor-nconghau.surge.sh`.
   * Public: Deploy `download.html` + `dist/` -> `https://agy-monitor.surge.sh`.
5. **Git Audit**: Commit with semantic message (`git commit -m "fix/feat: ..."`) and push to `origin main`.

---

## 🏗️ Command Reference

```bash
# Production one-command build & install
./scripts/build.sh

# Create new versioned release archive (e.g. v2.1.0)
./scripts/build-version.sh 2.1.0

# Deploy personal live stream from local Mac brain
./deploy-personal.sh

# Inspect app binary architecture
lipo -info /Applications/AntigravityMonitor.app/Contents/MacOS/AntigravityMonitor

# Refresh macOS LaunchServices icon database
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/AntigravityMonitor.app
```

---

## 🚫 Common Pitfalls (Avoid These)

1. ❌ Copying `AppIcon.icns` only into `assets/` → ✅ MUST copy directly to `Contents/Resources/AppIcon.icns`.
2. ❌ Forgetting `SetFile -a C` on DMG staging → ✅ Always set custom icon flag on DMG volume.
3. ❌ Compiling only `arm64` on Apple Silicon → ✅ Always compile `arm64` + `x86_64` universal binary.
4. ❌ Modifying UI header without testing narrow viewports → ✅ Ensure Tier 2 toolbar has `overflow-x-auto no-scrollbar`.
5. ❌ Slicing strings into button text causing truncation → ✅ Use compact timer formatting + full title in tooltip.
6. ❌ Committing private scripts or `.env` files → ✅ Keep `deploy-personal.sh` and private data in `.gitignore`.
