# 🔥 Notchd

> Your GitHub contribution graph, living in the MacBook notch.

Notchd is a macOS menu bar app that turns your Dynamic Island into a GitHub activity dashboard. Hover near the notch — your contribution grid springs open with animated flames, streak tracking, and per-cell entrance effects. Move away and it disappears. No dock icon. No clutter.

---

## Features

- **Hover-to-open** — Move your cursor near the notch to open, move away to close. No clicks needed.
- **Notch-native panel** — The overlay merges with the Dynamic Island using a pitch-black background and spring animation that expands from the notch.
- **Lottie streak flames** — Animated fire that scales in speed and size with your streak tier (1 day flicker → 30+ day inferno).
- **Contribution grid** — Last 6 months of data with a randomised cell entrance animation and a 1-second blink effect on open.
- **Streak tracking** — Shows your current streak, today's contribution count, and an "at risk" warning if you haven't contributed yet today.
- **Keychain-secured PAT** — Your GitHub Personal Access Token is stored in macOS Keychain. Never plaintext, never leaves your machine.
- **Settings panel** — GitHub username + PAT config, accessible via the gear icon inside the overlay.
- **Quit button** — Settings → Quit Notchd.

---

## Requirements

- macOS 13 Ventura or later
- A MacBook with a notch (MacBook Pro 14" / 16" / MacBook Air M2+)
- A GitHub Personal Access Token with `read:user` scope

---

## Installation

### Option A — DMG (easiest)

1. Download the latest `Notchd.dmg` from [Releases](https://github.com/deveshrohan/notchd/releases)
2. Open the DMG and drag **Notchd** into **Applications**
3. Launch it — a flame icon appears in the menu bar
4. Click the icon (or hover the notch) → tap the gear → enter your GitHub username and PAT

### Option B — Build from source

```bash
git clone https://github.com/deveshrohan/notchd.git
cd notchd
open gitTracker.xcodeproj
```

Select the `gitTracker` scheme, hit **Run** (⌘R). Xcode will automatically resolve the Lottie SPM dependency.

---

## Getting a GitHub Token

1. Go to [github.com/settings/tokens/new](https://github.com/settings/tokens/new)
2. Give it a name (e.g. `notchd`)
3. Check **`read:user`** scope
4. Generate and copy the token
5. Paste it into Notchd's Settings panel

---

## How it works

| Component | Role |
|---|---|
| `NotchPanelController` | Manages the `NSPanel` positioned behind the notch; hover monitor drives open/close |
| `PanelState` | Shared observable that bridges controller → SwiftUI for spring entry/exit animation |
| `NotchPositionDetector` | Reads `NSScreen.safeAreaInsets.top` to get true notch height and center |
| `ContributionViewModel` | Fetches GitHub GraphQL API, computes streak, caches weeks |
| `GitHubService` | `contributionCalendar` GraphQL query → typed model |
| `KeychainService` | `SecItem*` CRUD for PAT under `com.devesh.notchd` |
| `ContributionGridView` | Random cell entrance (Task loop) + 1-second blink effect |
| `AnimatedFlameView` | Lottie `flame.json` at speed proportional to streak tier |

---

## Project structure

```
gitTracker/
├── App/
│   ├── gitTrackerApp.swift       # @main entry, NSApplicationDelegateAdaptor
│   └── AppDelegate.swift         # NSStatusItem, initialises controllers
├── Window/
│   ├── NotchPanel.swift          # NSPanel subclass (borderless, non-activating)
│   ├── NotchPanelController.swift# Show/hide logic, hover & click monitors
│   ├── NotchPositionDetector.swift
│   ├── PanelState.swift          # Shared open/close state for SwiftUI animation
│   └── StreakNudgeController.swift
├── Views/
│   ├── ContentView.swift         # Root view, spring animation, black background
│   ├── ContributionPanelView.swift
│   ├── ContributionGridView.swift# Random entrance + blink Task loops
│   ├── ContributionCellView.swift
│   ├── AnimatedFlameView.swift   # Lottie flame, speed by streak tier
│   ├── PanelHeaderView.swift
│   ├── SettingsView.swift
│   └── StreakNudgeView.swift
├── ViewModels/
│   ├── ContributionViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── GitHubService.swift
│   └── KeychainService.swift
├── Models/
│   ├── ContributionData.swift
│   ├── ContributionDay.swift
│   └── ContributionWeek.swift
├── Utilities/
│   ├── ColorPalette.swift
│   └── AnimationConstants.swift
└── Resources/
    └── flame.json                # Lottie animation (CC0, lottiefiles.com)
```

---

## Dependencies

| Package | Version | License |
|---|---|---|
| [lottie-spm](https://github.com/airbnb/lottie-spm) | 4.5.0 | Apache 2.0 |

Resolved automatically by Xcode's Swift Package Manager.

---

## Contributing

Issues and PRs welcome. The project is intentionally small — keep it that way.

---

## License

MIT © [deveshrohan](https://github.com/deveshrohan)
