<p align="center">
  <img src="./assets/logo.jpg" width="96" height="96" style="border-radius: 24px; box-shadow: 0 10px 25px rgba(245, 158, 11, 0.3);" alt="Antigravity Monitor Logo"/>
</p>

<h1 align="center">🎮 Antigravity Monitor</h1>

<p align="center">
  <b>Pixel-Art Game Dev Studio Visualizer & Real-time Mission Control for Autonomous Coding Agents</b>
</p>

<p align="center">
  <a href="https://github.com/nconghau/AntigravityMonitor/releases"><img src="https://img.shields.io/badge/Release-v2.5_Universal-amber?style=for-the-badge&logo=apple" alt="Release v2.5 Universal"/></a>
  <a href="https://antigravity-monitor.surge.sh"><img src="https://img.shields.io/badge/Live_Web-antigravity--monitor.surge.sh-6366f1?style=for-the-badge&logo=safari" alt="Live Web"/></a>
  <a href="https://github.com/nconghau/AntigravityMonitor/stargazers"><img src="https://img.shields.io/github/stars/nconghau/AntigravityMonitor?style=for-the-badge&color=f59e0b" alt="GitHub Stars"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-emerald?style=for-the-badge" alt="License MIT"/></a>
</p>

---

## 🌟 What is Antigravity Monitor?

**Antigravity Monitor** turns the terminal-based autonomous coding agents of **Google DeepMind Antigravity** into a charming, living **Game Dev Story isometric studio**.

Instead of staring at terminal text logs or wondering which agent is running, your agents wander, code, drink espresso, lounge on the sofa, and sleep in cozy pods based on their actual real-time execution state.

<p align="center">
  <img src="https://antigravity-monitor.surge.sh/assets/logo.jpg" width="700" style="border-radius: 16px; border: 2px solid #e2e8f0;" alt="Antigravity Studio Preview"/>
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

### 4. 📻 Offline Web Audio Jukebox & Interactive SFX
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

👉 **Visit the Download Landing Page**: **[https://antigravity-monitor.surge.sh/download](https://antigravity-monitor.surge.sh/download)**

### 🍏 macOS (Universal: Apple Silicon M1-M4 & Intel)
1. Download **[AntigravityMonitor-macOS-Universal.dmg](https://github.com/nconghau/AntigravityMonitor/releases/download/v2.5/AntigravityMonitor-macOS-Universal.dmg)** *(9.2 MB)*.
2. Drag `AntigravityMonitor.app` into `/Applications`.
3. **Bypass macOS Gatekeeper on first launch**:
   ```bash
   xattr -cr /Applications/AntigravityMonitor.app
   ```

### 📱 Web & Mobile (iOS / Android / PWA)
Open directly in your mobile browser:
👉 **[https://antigravity-monitor.surge.sh](https://antigravity-monitor.surge.sh)**
*(Tip: Tap "Add to Home Screen" in Safari or Chrome to use it like a native mobile app).*

### 🐧 Windows & Linux
Clone this repo and open `app.html` in Chrome, Brave, or Edge!

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
| :---: | :--- |
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
