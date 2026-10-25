<p align="center">
  <img src="./assets/logo.jpg" width="96" height="96" alt="Antigravity Monitor logo"/>
</p>

<h1 align="center">Antigravity Monitor</h1>

<p align="center">
  <b>A playful macOS command center for autonomous coding agents.</b><br/>
  Watch your agents work, rest, ship, and celebrate inside a tiny game-dev studio.
</p>

<p align="center">
  <a href="https://agy-monitor.surge.sh"><img src="https://img.shields.io/badge/Explore-Landing_Page-6366f1?style=for-the-badge" alt="Explore landing page"/></a>
  <a href="https://agy-monitor.surge.sh/downloads/AntigravityMonitor-macOS-Universal.dmg"><img src="https://img.shields.io/badge/Download-macOS_Universal-f59e0b?style=for-the-badge&logo=apple" alt="Download macOS app"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-10b981?style=for-the-badge" alt="MIT license"/></a>
</p>

## Why it is fun

- **Living agent studio** — four rooms, expressive chibi bots, playful interactions, and a tiny Butter mascot.
- **Vibe Coding Sprint Tracker** — focused countdowns with seconds, progress motion, quick extensions, and agent activity.
- **Agent skills** — assign capabilities such as Semantic HTML, Playful UI, Switch & Toggle UI, Responsive Layout, Accessibility, Debugging, Review, and Build & Deploy.
- **Focus-friendly details** — rich tooltips, live steps, working-agent prioritization, bilingual EN/VI UI, and offline Web Audio ambience.

For the full product story, screenshots, and downloads, visit the [landing page](https://agy-monitor.surge.sh).

## Quick start

### macOS

Download the [Universal DMG](https://agy-monitor.surge.sh/downloads/AntigravityMonitor-macOS-Universal.dmg), drag the app to `/Applications`, then launch it.

### From source

```bash
git clone git@github.com-nconghau:nconghau/AntigravityMonitor.git
cd AntigravityMonitor
./scripts/build.sh
```

The production build compiles an arm64 + x86_64 Universal app, packages the icon and assets, signs and verifies the bundle, refreshes LaunchServices, creates DMG/ZIP artifacts, and installs the app to `/Applications`.

## Versioned releases

Keep every release reproducible and separate:

```bash
cat VERSION
./scripts/build-version.sh 2.2.0
```

Artifacts are written to `releases/v<version>/`. Existing releases are protected from accidental overwrite; use `FORCE=1` only when intentionally rebuilding the same version.

## Shortcuts

| Key | Action |
| --- | --- |
| `T` | Open the Vibe Coding Sprint Tracker |
| `H` | Switch Studio / Dashboard views |
| `S` | Inspect the selected agent's steps |
| `C` | Open Studio Customizer and Agent Skills |
| `R` | Refresh live agent data |
| `J` | Toggle the Lo-fi Jukebox |
| `Esc` | Close the active modal or zoom |

## Stack

Native Swift + AppKit/WebKit wrapper, with a vanilla HTML/CSS/JavaScript interface and zero frontend build dependencies.

## License

MIT — see [LICENSE](LICENSE).
