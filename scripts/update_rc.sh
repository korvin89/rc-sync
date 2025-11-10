#!/usr/bin/env bash
set -euo pipefail

# ---------- Config ----------
RAW_BASE="https://raw.githubusercontent.com/korvin89/rc-sync/main"
SNIPPET_URL="${RAW_BASE}/scripts/rc_snippet.sh"
MARK_START="# >>> bashrc-sync start"
MARK_END="# <<< bashrc-sync end"

# allow override: TARGET_RC=~/.bashrc bash update_rc.sh
is_zsh=0
if [[ -n "${TARGET_RC:-}" ]]; then
  TARGET="$TARGET_RC"
  if [[ "$TARGET" == *".zshrc"* ]]; then
    is_zsh=1
  fi
else
  # try to guess
  if [[ -n "${ZSH_VERSION:-}" || "${SHELL##*/}" = "zsh" ]]; then
    TARGET="$HOME/.zshrc"
    is_zsh=1
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

# extract relevant part
SNIPPET_CONTENT_FILE="$(mktemp)"
if [[ "$is_zsh" -eq 1 ]]; then
  awk '/# ===== zsh prompt start =====/{p=1;next} /# ===== zsh prompt end =====/{p=0} p' "$TMP" > "$SNIPPET_CONTENT_FILE"
else
  awk '/# ===== bash prompt start =====/{p=1;next} /# ===== bash prompt end =====/{p=0} p' "$TMP" > "$SNIPPET_CONTENT_FILE"
fi

# build block with markers
BLOCK="$(mktemp)"
{
  echo
  echo "$MARK_START"
  cat "$SNIPPET_CONTENT_FILE"
  echo "$MARK_END"
  echo
} > "$BLOCK"

# replace existing block or append
if grep -qF "$MARK_START" "$TARGET"; then
  # Replace between markers (inclusive)
  awk -v start="$MARK_START" -v end="$MARK_END" '
    BEGIN {inblock=0}
    $0==start {print; system("cat '"$SNIPPET_CONTENT_FILE"'"); print end; inblock=1; next}
    $0==end && inblock {inblock=0; next}
    !inblock {print}
  ' "$TARGET" > "${TARGET}.tmp" && mv "${TARGET}.tmp" "$TARGET"
else
  cat "$BLOCK" >> "$TARGET"
fi

rm -f "$TMP" "$BLOCK" "$SNIPPET_CONTENT_FILE"

echo "✅ Updated $TARGET"
echo "→ Reload your shell:  source $TARGET"
