#!/usr/bin/env bash
set -euo pipefail

# ---------- Config ----------
RAW_BASE="https://raw.githubusercontent.com/korvin89/rc-sync/main"
SNIPPET_URL="${RAW_BASE}/rc_snippet.sh"
MARK_START="# >>> bashrc-sync start"
MARK_END="# <<< bashrc-sync end"

# allow override: TARGET_RC=~/.bashrc bash update_rc.sh
if [[ -n "${TARGET_RC:-}" ]]; then
  TARGET="$TARGET_RC"
else
  # try to guess
  if [[ -n "${ZSH_VERSION:-}" || "${SHELL##*/}" = "zsh" ]]; then
    TARGET="$HOME/.zshrc"
  else
    TARGET="$HOME/.bashrc"
  fi
fi

# choose fetcher
fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$1"
  else
    echo "Error: need curl or wget" >&2
    exit 1
  fi
}

# ensure target exists
touch "$TARGET"

# backup
ts="$(date +%Y%m%d-%H%M%S)"
cp "$TARGET" "${TARGET}.bak-${ts}"

# download snippet
TMP="$(mktemp)"
fetch "$SNIPPET_URL" > "$TMP"

# build block with markers
BLOCK="$(mktemp)"
{
  echo
  echo "$MARK_START"
  cat "$TMP"
  echo "$MARK_END"
  echo
} > "$BLOCK"

# replace existing block or append
if grep -qF "$MARK_START" "$TARGET"; then
  # Replace between markers (inclusive)
  awk -v start="$MARK_START" -v end="$MARK_END" '
    BEGIN {inblock=0}
    $0==start {print; system("cat '"$TMP"'"); print end; inblock=1; next}
    $0==end && inblock {inblock=0; next}
    !inblock {print}
  ' "$TARGET" > "${TARGET}.tmp" && mv "${TARGET}.tmp" "$TARGET"
else
  cat "$BLOCK" >> "$TARGET"
fi

rm -f "$TMP" "$BLOCK"

echo "✅ Updated $TARGET"
echo "→ Reload your shell:  source $TARGET"
