<p align="center">
  <img src="./assets/logo.jpg" width="96" height="96" style="border-radius: 24px; box-shadow: 0 10px 25px rgba(245, 158, 11, 0.3);" alt="Antigravity Monitor Logo"/>
</p>

<h1 align="center">🎮 Antigravity Monitor</h1>

<p align="center">
  <b>Pixel-Art Game Dev Studio Visualizer & Real-time Mission Control for Autonomous Coding Agents</b>
</p>

<p align="center">
  <a href="https://agy-monitor.surge.sh/download"><img src="https://img.shields.io/badge/Release-v2.5_Universal-amber?style=for-the-badge&logo=apple" alt="Release v2.5 Universal"/></a>
  <a href="https://agy-monitor.surge.sh"><img src="https://img.shields.io/badge/Live_Web-agy--monitor.surge.sh-6366f1?style=for-the-badge&logo=safari" alt="Live Web"/></a>
  <a href="https://github.com/nconghau/AntigravityMonitor/stargazers"><img src="https://img.shields.io/github/stars/nconghau/AntigravityMonitor?style=for-the-badge&color=f59e0b" alt="GitHub Stars"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-emerald?style=for-the-badge" alt="License MIT"/></a>
</p>

---

## 🌟 What is Antigravity Monitor?

**Antigravity Monitor** turns the terminal-based autonomous coding agents of **Google DeepMind Antigravity** into a charming, living **Game Dev Story isometric studio**.

Instead of staring at terminal text logs or wondering which agent is running, your agents wander, code, drink espresso, lounge on the sofa, and sleep in cozy pods based on their actual real-time execution state.

<p align="center">
  <img src="https://agy-monitor.surge.sh/assets/logo.jpg" width="700" style="border-radius: 16px; border: 2px solid #e2e8f0;" alt="Antigravity Studio Preview"/>
</p>

---

## ✨ Key Features

### 1. 🏡 4-Room Isometric Studio Map
* **💻 Dev Lab (Office)**: Active agents type on laptops with mechanical sounds and fever-mode animations.
* **🍳 Kitchen & Cafe Bar**: Agents drink espresso or eat pizza when relaxing between tasks.
* **🛋️ Studio Lounge**: Watch Lo-fi TV with **Mèo Bơ Mascot** 🐱.
* **🛏️ Sleep Pod (Bedroom)**: Agents rest in pods with floating `💤 Zzz` bubbles when idle.

### 2. 🎭 14 Diverse Transparent Cutout Characters
Say goodbye to rigid square avatars! Every agent receives a unique, freestanding cutout character with soft shadows and an amber selection glow:
* **Dev Bot** • **Deployer Bot** • **Guardian Bot** • **Shadow Ninja** • **Astro Bot** • **Wizard AI** • **Titan Mech** • **Kitsune Dev** • **Sherlock AI** • **Barista Bot** • **Dino Junior** • **Neon Cyberpunk** • **Alien Coder** • **Mèo Bơ Mascot**

### 3. ⚡ 100% Live Data & Zero-Flicker DOM Diffing
* High-performance in-place DOM reconciliation (Zero screen flickering / blinking).
* Accurate real-time counters: **Tất cả (Total)**, **⚡ Chạy (Active)**, **☕ Nghỉ (Idle)**.
* **Built-in Watchdog**: Automatically resolves long-running or hung background tasks.

### 4. 🎨 Playful Studio Customizer Hub (Hotkeys: `C`)
* **Custom Theme Colors**: Choose from 6 playful presets (*Mật Ong Ấm, Dâu Tây Sữa, Trà Xanh Mint, Kẹo Nho, Biển Xanh Cyan, Đêm Neon*) or design your own studio palette using real-time color pickers (Background, Wooden Floor, Glass Cards, Accent Aura, and Text).
* **Custom Music Sources**: Listen to offline synthesized Lo-fi/Chiptune audio, add direct internet radio/MP3 streams (e.g. *Lofi Girl live*), or upload your favorite local audio tracks (`.mp3`, `.wav`, `.m4a`) directly from your machine into the Jukebox playlist.
* **Custom AI Agents**: Create custom agents or customize existing ones with custom names, roles, default rooms, speech bubble dialogs, and select from the 14 transparent chibi characters or specify your own image avatar URL.

### 5. 📻 Offline Web Audio Jukebox & Interactive SFX
* 5 synthesized ambient soundtracks (100% Offline, 0 external audio dependencies):
  1. ☕ **Lo-fi Study Cafe**
  2. 🕹️ **8-Bit Chiptune Arcade**
  3. 🌆 **Cyberpunk Synthwave**
  4. 🌧️ **Coffee & Gentle Rain**
  5. 🔔 **Zen Focus & Tibetan Bowls**
* Interactive particle bursts (**Confetti & Sparkles**) on click and mechanical keyboard typewriter sound effects.

### 5. 🩺 Auto-Diagnostics & 1-Click Environment Setup
* Automatically scans `~/.gemini/antigravity/brain` and `~/.gemini/antigravity-ide/brain`.
* Instant visual alert badge: `🩺 Cấu Hình OK` or `⚠️ Cần Kiểm Tra`.
* **1-Click Sample Folder Generator**: Enables first-time users without Antigravity installed to test and experience the app immediately!

### 6. 🧠 Quota Meter & Multi-Model Breakdown
* Prominent `% Quota Còn Lại` indicator with mini progress bar.
* Live tracking for **Gemini 3.8 Flash**, **Claude Sonnet 4.6 (Thinking)**, **Claude Opus 4.6**, and **GPT-OSS 120B**.

---

## 🚀 Quick Download & Install (Cross-Platform)

👉 **Visit the Download Landing Page**: **[https://agy-monitor.surge.sh/download](https://agy-monitor.surge.sh/download)**

### 🍏 macOS (Universal: Apple Silicon M1-M4 & Intel)
1. **Direct Download**: **[AntigravityMonitor-macOS-Universal.dmg](https://agy-monitor.surge.sh/downloads/AntigravityMonitor-macOS-Universal.dmg)** *(12 MB)* or **[.ZIP](https://agy-monitor.surge.sh/downloads/AntigravityMonitor-macOS-Universal.zip)**.
2. Drag `AntigravityMonitor.app` into `/Applications`.
3. **Bypass macOS Gatekeeper on first launch**:
   ```bash
   xattr -cr /Applications/AntigravityMonitor.app
   ```

### 📱 Web & Mobile (iOS / Android / PWA)
Open directly in your mobile or desktop browser:
👉 **[https://agy-monitor.surge.sh](https://agy-monitor.surge.sh)**
*(Tip: Tap "Add to Home Screen" in Safari or Chrome to use it full-screen like a native mobile app).*

---

## 🪟 Windows & Linux Desktop Guide

You can easily run Antigravity Monitor as a standalone desktop app on **Windows** and **Linux** without compiling Xcode / Swift:

### 1. 🪟 Windows (Standalone App Mode)
* **Method A (Instant Edge / Chrome App Window)**:
  Open PowerShell in the project directory and run:
  ```powershell
  Start-Process msedge.exe -ArgumentList "--app=https://agy-monitor.surge.sh", "--window-size=1200,800"
  ```
  *(Or point directly to your local file: `--app="file://$PWD/app.html"`)*

* **Method B (Install as Windows PWA)**:
  1. Open [https://agy-monitor.surge.sh](https://agy-monitor.surge.sh) in Microsoft Edge or Google Chrome.
  2. Click the **Install Antigravity Monitor** icon in the right side of the URL bar (or Menu `...` -> *Apps* -> *Install this site as an app*).
  3. The app will launch in its own frameless window with a desktop shortcut and pin to your Windows Taskbar!

### 2. 🐧 Linux (Ubuntu, Debian, Fedora, Arch)
* **Method A (Chromium / Chrome App Mode)**:
  ```bash
  chromium-browser --app="https://agy-monitor.surge.sh" --window-size=1200,800
  # Or with local HTML:
  google-chrome --app="file://$(pwd)/app.html" --window-size=1200,800
  ```

* **Method B (Ultra-lightweight Python Webview Desktop)**:
  ```bash
  pip install pywebview
  python3 -c "import webview; webview.create_window('Antigravity Monitor', 'app.html', width=1200, height=800); webview.start()"
  ```

* **Method C (Create a Linux Desktop Shortcut)**:
  Create `~/.local/share/applications/antigravity-monitor.desktop`:
  ```ini
  [Desktop Entry]
  Name=Antigravity Monitor
  Comment=Pixel-Art Game Dev Studio Visualizer for AI Coding Agents
  Exec=chromium --app=https://agy-monitor.surge.sh
  Icon=/path/to/assets/logo.jpg
  Terminal=false
  Type=Application
  Categories=Development;Utility;
  ```

---

## 🌐 Deploy Your Own Free Web App to Surge.sh

Want to host your own personal or team Antigravity Studio on your own custom subdomain (e.g., `my-studio.surge.sh`)? Surge provides 100% free static web hosting with unlimited traffic:

```bash
# 1. Install Surge CLI globally
npm install --global surge

# 2. Clone repository & enter directory
git clone https://github.com/nconghau/AntigravityMonitor.git
cd AntigravityMonitor

# 3. Deploy to your custom domain
surge . --domain my-ai-studio.surge.sh

# 4. Access your live studio immediately at:
# https://my-ai-studio.surge.sh
```
> **Tip**: Whenever you update `app.html` or customize bots/themes, simply run `surge . --domain my-ai-studio.surge.sh` again to update in under 5 seconds!

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
| :---: | :--- |
| **`C`** | Open **🎨 Studio Customizer** (Theme, Custom Music & Custom Agents) |
| **`H`** | Toggle between **🏡 2D Studio Map** and **🏢 List Dashboard** |
| **`J`** | Toggle **📻 Jukebox & Music Player** |
| **`D`** | Open **🩺 Antigravity System Diagnostics** |
| **`U`** | View **🧠 Remaining Quota & Model Hub** |
| **`S`** | Inspect current agent execution steps & logs |
| **`R`** | Force refresh Live Data immediately |
| **`T`** | Cycle themes: Cozy Day, Pastel Dream, Nordic Clean, Retro Cafe, Cyber Dark |
| **`F`** | Toggle **⚡ Fever Mode** (100 WPM typing speed for all agents) |
| **`M`** | Toggle sound effects (SFX) |
| **`Esc`** | Close modal or reset room zoom |

---

## 🛠️ Architecture & Local Build

Antigravity Monitor is built with native **SwiftUI / AppKit** for macOS MenuBar integration and a zero-dependency **HTML5 / TailwindCSS / Web Audio API** visualizer rendered inside a lightweight `WKWebView`.

```bash
# 1. Clone repository
git clone git@github.com-nconghau:nconghau/AntigravityMonitor.git
cd AntigravityMonitor

# 2. Compile Universal Binary (Apple Silicon + Intel)
swiftc -parse-as-library -target arm64-apple-macos12.0 -O -o build/AntigravityMonitor_arm64 AntigravityMonitor.swift
swiftc -parse-as-library -target x86_64-apple-macos12.0 -O -o build/AntigravityMonitor_x86_64 AntigravityMonitor.swift
lipo -create -output dist/AntigravityMonitor.app/Contents/MacOS/AntigravityMonitor build/AntigravityMonitor_arm64 build/AntigravityMonitor_x86_64

# 3. Codesign App
codesign --force --deep -s - dist/AntigravityMonitor.app
```

---

## 🌐 Community & GitHub SEO Optimization

To maximize visibility and discovery on GitHub:

### Recommended Topics / Tags
```
antigravity, google-antigravity, ai-agents, autonomous-agents, agent-monitor, 
developer-tools, game-dev-story, pixel-art, lofi-music, macos-menubar, swiftui, webkit
```

### Social Preview / SEO Description
> *🎮 Pixel-Art Game Dev Studio Visualizer & MenuBar Monitor for Google DeepMind Antigravity coding agents. Real-time live data, lo-fi jukebox, multi-agent tracking, and macOS universal app.*

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---

<p align="center">
  Crafted with ❤️ for the AI Developer Community by <a href="https://github.com/nconghau"><b>@nconghau</b></a>
</p>
