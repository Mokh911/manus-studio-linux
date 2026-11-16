<div align="center">

# Manus Studio on Linux

**Run the official Manus Studio desktop app on Linux.**

Manus ships Studio for macOS and Windows only — there is no Linux build.
This project downloads the **official** macOS package from Manus's own
servers, extracts the application payload, and runs it on the matching
Linux Electron runtime. Nothing from the app is hosted in this repository.

[![Platform](https://img.shields.io/badge/platform-Linux_x86_64-blue)](https://github.com/Mokh911/manus-studio-linux)
[![Manus Studio](https://img.shields.io/badge/Manus_Studio-2.0.7-8A2BE2)](https://manus.im/download)
[![Electron](https://img.shields.io/badge/Electron-43.6.0-47848F?logo=electron&logoColor=white)](https://www.electronjs.org)
[![License](https://img.shields.io/badge/wrapper_license-MIT-green)](LICENSE)
[![Unofficial](https://img.shields.io/badge/status-unofficial-orange)](#-disclaimer)

**[English](README.md) · [العربية](README.ar.md)**

</div>

---

## ⚠️ Disclaimer

- This is an **unofficial** community wrapper. It is **not** affiliated with,
  endorsed by, or sponsored by [Manus](https://manus.im).
- The Manus Studio application itself is **not included** in this repository.
  `install.sh` downloads the official installer from `download.manus.im`
  (Manus's own CDN) over HTTPS and runs it locally.
- Manus Studio and its assets remain the property of their respective owner —
  see [NOTICE](NOTICE). If you are a Manus representative and want this taken
  down, open an issue and it will be removed promptly.

## ✨ How it works

```
Manus-Setup-<version>.dmg          ← official macOS package (download.manus.im)
        │  7-Zip
        ▼
Contents/Resources/app.asar        ← the actual application (same code the
        │                            macOS/Windows builds run)
        ▼
~/.local/share/manus-studio/app/   ← installed payload
        +
Electron <version> Linux x86_64    ← official Linux Electron runtime
        │
        ▼
manus-studio                       ← wrapper that launches the app
```

The Electron version used here (`43.6.0`) matches the runtime version the
official 2.0.7 build targets, so the app runs on the environment it was built
against.

## 📦 Requirements

| Requirement | Notes |
|---|---|
| Linux x86_64 | 64-bit Intel/AMD |
| ~1.5 GB disk | payload + Electron runtime |
| `curl` | for downloads |
| `7-Zip` (`p7zip-full`) | to unpack the .dmg |
| X11/Wayland desktop session | GUI app |

## 🚀 Install

One-liner (no clone needed):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mokh911/manus-studio-linux/main/install.sh)
```

Or clone first:

```bash
git clone https://github.com/Mokh911/manus-studio-linux.git
cd manus-studio-linux
./install.sh
```

Offline install from a `.dmg` you already have:

```bash
MANUS_DMG=/path/to/Manus-Setup-2.0.7.dmg ./install.sh
```

### What gets installed where

| Item | Path |
|---|---|
| Install root | `~/.local/share/manus-studio/` |
| App payload | `~/.local/share/manus-studio/app/` |
| Electron runtime | `~/.local/share/manus-studio/electron/` |
| Launcher | `~/.local/bin/manus-studio` |
| Menu entry | `~/.local/share/applications/manus-studio.desktop` |
| Profile (login session) | `~/.config/Manus Studio/` |

## ⚙️ Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `MANUS_VERSION` | `2.0.7` | Manus Studio version to install |
| `ELECTRON_VERSION` | `43.6.0` | Electron runtime version |
| `MANUS_STUDIO_HOME` | `~/.local/share/manus-studio` | install root |
| `MANUS_STUDIO_USER_DATA` | `~/.config/Manus Studio` | profile directory |
| `MANUS_DMG` | — | install from a local `.dmg` file |
| `MANUS_STUDIO_SKIP_DESKTOP` | `0` | set `1` to skip the menu entry |

## 🔑 First sign-in

1. Launch **Manus Studio** from your applications menu, or run `manus-studio`.
2. The app shows **Sign in to Manus** → press **Sign in** — your browser opens
   on `manus.im/login`.
3. Sign in inside the browser.
4. The browser redirects to `manuslocal://app?token=…` — the protocol handler
   registered by the installer captures it and the app completes sign-in
   automatically.

If the redirect does not come back to the app, check:

```bash
xdg-mime query default x-scheme-handler/manuslocal
# should print: manus-studio.desktop
```

## 🧪 What works / what does not

Tested on one machine (Ubuntu, x86_64, Intel Haswell iGPU) — see
[docs/TESTING.md](docs/TESTING.md) for the full evidence.

| Feature | Status | Reason |
|---|---|---|
| Chat, tasks, cloud agents | ✅ works | served by `api.manus.im` |
| Browser-based sign-in | ✅ works | `manuslocal://` protocol registered |
| **My Computer (local device control)** | ❌ not available | the official payload ships computer-use helpers for macOS/Windows only — there is no Linux helper in the package |
| System tray | ⚠️ disabled | macOS/Windows tray integration; closing the window quits the app |
| Graphics acceleration | ⚠️ software | runs with `--disable-gpu --enable-unsafe-swiftshader` |

## 🧯 Troubleshooting

- **App does not start** — run the launcher from a terminal and read the error:
  `manus-studio`. Missing Electron or payload means re-run `install.sh`.
- **Blank window on some GPUs** — the flags in the launcher already disable
  GPU. If you have a working GPU driver, you can try removing
  `--disable-gpu --enable-unsafe-swiftshader` from `~/.local/bin/manus-studio`.
- **Sign-in redirect lost** — re-check the `manuslocal://` handler (above), or
  sign in again.
- **Wrong version downloaded** — set `MANUS_VERSION`:
  `MANUS_VERSION=2.0.7 ./install.sh`. Current published versions can be
  checked at <https://manus.im/download>.
- **Completely remove everything:**

  ```bash
  bash ~/.local/share/manus-studio/uninstall.sh
  ```

## ❓ FAQ

**Is this official?**
No. See the disclaimer. The application payload is the official one, but the
Linux packaging is a community wrapper.

**Is it safe?**
The payload is downloaded over HTTPS from Manus's own servers
(`download.manus.im`) — the same installer macOS/Windows users get. This repo
contains no binaries, no patched code, and no re-hosted files.

**Why not an AppImage / .deb?**
Kept intentionally simple: one script, no packaging maintenance. PRs welcome.

**Does it auto-update?**
No. The official updater expects the packaged app. To update, re-run
`install.sh` with the new `MANUS_VERSION`.

## 📄 License

The wrapper scripts in this repository are released under the
[MIT License](LICENSE). **Manus Studio itself is not covered by this license**
and is not distributed here — see [NOTICE](NOTICE).
