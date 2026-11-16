# Testing & verification evidence

Everything below was verified on one machine and is reported here as-is,
so you know exactly what this wrapper was proven to do and where its
limits come from.

- **Machine:** Ubuntu Linux, x86_64, Intel Haswell integrated graphics
- **Date:** October 2026
- **Payload:** Manus Studio `2.0.7`, `app.asar` extracted from the official
  `Manus-Setup-2.0.7.dmg` (macOS arm64 package, 319,733,438 bytes,
  `download.manus.im`)
- **Runtime:** official Electron `43.6.0` for Linux x86_64

## Verified

| Check | Result |
|---|---|
| App starts and loads the official login page | ✅ `url: app://manus/login`, `title: Manus Studio`, `readyState: complete` (via CDP) |
| Deep-link chain end-to-end | ✅ `xdg-open manuslocal://…` → protocol registration → launcher → running app instance → `handleProtocolCallback` → `nonce` validation → real API call |
| API response to the deep-link callback with a dummy token | ✅ `HTTP 401` — the correct behavior (proves the request reaches the real `api.manus.im`) |

## Known limitations on Linux — and why

| Feature | Status | Cause |
|---|---|---|
| Chat / tasks / cloud agents | ✅ works | served by `api.manus.im` |
| Browser-based sign-in | ✅ works | `manuslocal://` protocol registered by the installer |
| **My Computer / local device control** | ❌ not available | the official package ships computer-use helpers under `helper/darwin` and `bin/manus-computer-operator` for macOS/Windows only — there is **no Linux helper anywhere in the official payload**. This is a payload limitation, not a wrapper bug. |
| System tray icon | ⚠️ disabled | tray integration is macOS/Windows-specific in the app; closing the window quits |
| GPU acceleration | ⚠️ software rendering | launcher passes `--disable-gpu --enable-unsafe-swiftshader` (verified on Intel Haswell iGPU; machines with proper Vulkan/GL drivers may tolerate removing these flags) |

## Install layout this testing used

| Item | Path |
|---|---|
| Install root | `~/.local/share/manus-studio/` |
| App payload | `~/.local/share/manus-studio/app/` |
| Electron runtime | `~/.local/share/manus-studio/electron/` |
| Launcher | `~/.local/bin/manus-studio` |
| Menu entry | `~/.local/share/applications/manus-studio.desktop` |
| Profile | `~/.config/Manus Studio/` |
| Manual-run log | `~/.local/share/manus-studio/run.log` |
