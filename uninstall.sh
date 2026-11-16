#!/usr/bin/env bash
#
# uninstall.sh — remove the Manus Studio (Linux) installation.
#
# Environment overrides:
#   MANUS_STUDIO_HOME   install root (default: ~/.local/share/manus-studio)
#   MANUS_STUDIO_KEEP_PROFILE=1   keep the login profile at ~/.config/"Manus Studio"
#
set -euo pipefail

INST="${MANUS_STUDIO_HOME:-$HOME/.local/share/manus-studio}"

# stop any running instance started from this install root (not other apps)
pkill -f "$INST" 2>/dev/null || true
sleep 1

rm -rf "$INST"
rm -f  "$HOME/.local/bin/manus-studio"
rm -f  "$HOME/.local/share/applications/manus-studio.desktop"

if [ "${MANUS_STUDIO_KEEP_PROFILE:-0}" != "1" ]; then
  rm -rf "$HOME/.config/Manus Studio"
fi

command -v update-desktop-database >/dev/null 2>&1 && \
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "Manus Studio (Linux) uninstalled."
[ "${MANUS_STUDIO_KEEP_PROFILE:-0}" = "1" ] && \
  echo "Login profile kept at: $HOME/.config/Manus Studio"
