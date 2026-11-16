#!/usr/bin/env bash
#
# install.sh — Manus Studio on Linux
#
# Downloads the OFFICIAL Manus Studio macOS installer from Manus's own
# servers, extracts the application payload, and runs it on the matching
# Electron runtime for Linux x86_64. No application files are hosted in
# this repository — everything is fetched from the official source.
#
# Usage:
#   bash install.sh                       # standard install
#   MANUS_DMG=/path/to.dmg bash install.sh  # offline install from a local .dmg
#
# Environment overrides:
#   MANUS_VERSION   Manus Studio version   (default: 2.0.7)
#   ELECTRON_VERSION  Electron version     (default: 43.6.0)
#   MANUS_STUDIO_HOME install root        (default: ~/.local/share/manus-studio)
#   MANUS_DMG       use a local .dmg instead of downloading
#   MANUS_STUDIO_SKIP_DESKTOP=1  do not register the .desktop entry
#
set -euo pipefail

MANUS_VERSION="${MANUS_VERSION:-2.0.7}"
ELECTRON_VERSION="${ELECTRON_VERSION:-43.6.0}"
INST="${MANUS_STUDIO_HOME:-$HOME/.local/share/manus-studio}"
LOCAL_DMG="${MANUS_DMG:-}"
SKIP_DESKTOP="${MANUS_STUDIO_SKIP_DESKTOP:-0}"
RAW_BASE="${MANUS_RAW_BASE:-https://raw.githubusercontent.com/Mokh911/manus-studio-linux/main}"

DMG_URL="https://download.manus.im/Manus-Setup-${MANUS_VERSION}.dmg"
EL_URL="https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-linux-x64.zip"
ICON_URL="https://manus.im/icon.png"

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- preflight ----------------------------------------------------------------
[ "$(uname -s)" = "Linux" ] || die "this installer is for Linux."
[ "$(uname -m)" = "x86_64" ] || die "only x86_64 (64-bit Intel/AMD) is supported."
command -v curl >/dev/null 2>&1 || die "curl is required."
command -v 7z >/dev/null 2>&1 || command -v 7zz >/dev/null 2>&1 \
  || die "7-Zip is required: sudo apt install p7zip-full"
SEVENZIP="$(command -v 7zz || command -v 7z)"

WORK="$(mktemp -d "${TMPDIR:-/var/tmp}/manus-studio-install.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

# --- 1. application payload ----------------------------------------------------
log "Extracting Manus Studio ${MANUS_VERSION} application payload…"

DMG_FILE="$WORK/Manus-Setup-${MANUS_VERSION}.dmg"
if [ -n "$LOCAL_DMG" ]; then
  [ -f "$LOCAL_DMG" ] || die "MANUS_DMG=$LOCAL_DMG does not exist."
  cp "$LOCAL_DMG" "$DMG_FILE"
else
  log "Downloading official installer (${DMG_URL})"
  curl -fL --retry 3 --output "$DMG_FILE" "$DMG_URL" \
    || die "download failed. get it manually from https://manus.im/download"
fi

log "Unpacking .dmg (this can take a minute)…"
"$SEVENZIP" x -y -o"$WORK/dmg" "$DMG_FILE" >/dev/null \
  || die "could not unpack the .dmg with 7-Zip."

ASAR="$(find "$WORK/dmg" -type f -name 'app.asar' -path '*Contents/Resources/*' | head -1)"
[ -n "$ASAR" ] || die "app.asar not found inside the .dmg — unsupported package layout."
UNPACKED="$(dirname "$ASAR")/app.asar.unpacked"

mkdir -p "$INST/app"
cp "$ASAR" "$INST/app/app.asar"
if [ -d "$UNPACKED" ]; then
  rm -rf "$INST/app/app.asar.unpacked"
  cp -R "$UNPACKED" "$INST/app/app.asar.unpacked"
fi
log "App payload installed to $INST/app"

# --- 2. Electron runtime --------------------------------------------------------
if [ -x "$INST/electron/electron" ]; then
  log "Electron already present at $INST/electron — skipping download."
else
  log "Downloading Electron ${ELECTRON_VERSION} for Linux x86_64…"
  curl -fL --retry 3 --output "$WORK/electron.zip" "$EL_URL" \
    || die "Electron download failed: $EL_URL"
  mkdir -p "$INST/electron"
  "$SEVENZIP" x -y -o"$INST/electron" "$WORK/electron.zip" >/dev/null \
    || die "could not unpack the Electron archive."
  chmod +x "$INST/electron/electron"
fi

# --- 3. launcher + desktop entry -------------------------------------------------
BIN="$HOME/.local/bin"
mkdir -p "$BIN"
if [ -f "$(dirname "${BASH_SOURCE[0]:-$0}")/bin/manus-studio" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
  install -m 755 "$SCRIPT_DIR/bin/manus-studio" "$BIN/manus-studio"
  if [ -f "$SCRIPT_DIR/uninstall.sh" ]; then
    install -m 755 "$SCRIPT_DIR/uninstall.sh" "$INST/uninstall.sh"
  fi
else
  # running via `curl | bash` — fetch the scripts from the repository
  curl -fsSL --output "$BIN/manus-studio" "$RAW_BASE/bin/manus-studio" \
    && chmod 755 "$BIN/manus-studio" \
    || die "could not fetch the launcher from $RAW_BASE"
  curl -fsSL --output "$INST/uninstall.sh" "$RAW_BASE/uninstall.sh" \
    && chmod 755 "$INST/uninstall.sh" || warn "could not fetch uninstall.sh (optional)."
fi

if [ "$SKIP_DESKTOP" != "1" ]; then
  log "Installing desktop entry and protocol handlers…"
  DESK="$HOME/.local/share/applications/manus-studio.desktop"
  mkdir -p "$HOME/.local/share/applications"

  ICON="$INST/icon.png"
  curl -fsSL --output "$ICON" "$ICON_URL" 2>/dev/null \
    || { warn "could not download the app icon (non-fatal)."; ICON=""; }
  if [ -n "$ICON" ] && [ "$(wc -c <"$ICON")" -lt 1000 ]; then
    warn "downloaded icon looks invalid — using default icon."
    ICON=""
  fi
  ICON_LINE=""; [ -n "$ICON" ] && ICON_LINE="Icon=$ICON"

  cat > "$DESK" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=Manus Studio
Name[ar]=مانوس ستوديو
GenericName=AI Agent
Comment=Official Manus Studio desktop app (macOS build running on Linux via Electron)
Comment[ar]=تطبيق Manus Studio الرسمي (نسخة الماك تشغيل على لينكس عبر Electron)
Exec=$BIN/manus-studio %u
$ICON_LINE
Terminal=false
Categories=Utility;Network;
Keywords=manus;ai;agent;studio;
MimeType=x-scheme-handler/manuslocal;x-scheme-handler/manus;
StartupWMClass=Manus Studio
StartupNotify=true
EOF

  command -v xdg-mime >/dev/null 2>&1 && {
    xdg-mime default manus-studio.desktop x-scheme-handler/manuslocal || true
    xdg-mime default manus-studio.desktop x-scheme-handler/manus || true
  }
  command -v update-desktop-database >/dev/null 2>&1 && \
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# --- done -------------------------------------------------------------------------
echo
log "Manus Studio ${MANUS_VERSION} installed successfully."
echo "  launch:      manus-studio   (or from your applications menu)"
echo "  install dir: $INST"
echo "  profile dir: $HOME/.config/Manus Studio"
echo "  uninstall:   bash $INST/uninstall.sh"
echo
echo "  First launch shows 'Sign in to Manus'. Sign-in completes in your"
echo "  browser and returns via the manuslocal:// protocol automatically."
echo "  Note: 'My Computer' (local device control) is macOS/Windows-only in"
echo "  the official build — see docs/TESTING.md in the repository."
