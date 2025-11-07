#!/usr/bin/env bash
set -euo pipefail

MARK_START="# >>> bashrc-sync start"
MARK_END="# <<< bashrc-sync end"

if [[ -n "${TARGET_RC:-}" ]]; then
  TARGET="$TARGET_RC"
else
  if [[ -n "${ZSH_VERSION:-}" || "${SHELL##*/}" = "zsh" ]]; then
    TARGET="$HOME/.zshrc"
  else
    TARGET="$HOME/.bashrc"
  fi
fi

[[ -f "$TARGET" ]] || { echo "Nothing to do: $TARGET not found"; exit 0; }

ts="$(date +%Y%m%d-%H%M%S)"
cp "$TARGET" "${TARGET}.bak-${ts}"

awk -v start="$MARK_START" -v end="$MARK_END" '
  BEGIN {inblock=0}
  $0==start {inblock=1; next}
  $0==end && inblock {inblock=0; next}
  !inblock {print}
' "$TARGET" > "${TARGET}.tmp" && mv "${TARGET}.tmp" "$TARGET"

echo "🧹 Removed snippet from $TARGET"
echo "Backup: ${TARGET}.bak-${ts}"
