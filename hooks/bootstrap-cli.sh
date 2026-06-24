#!/usr/bin/env bash
# SessionStart hook: if the jjakmal CLI tools are missing, NUDGE the user to install
# them — it does NOT install anything itself.
#
# Auto-installing would silently run `pip install` into whatever Python is active and
# symlink binaries into the user's PATH on session start. A plugin shouldn't mutate a
# user's environment without consent, so this only prints a one-time hint. Run the
# install yourself with ./install.sh.
set -uo pipefail

ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MARK="$HOME/.cache/jjakmal/.cli-nudge-shown"

# Tools already present? Nothing to say.
if command -v kollocate >/dev/null 2>&1 \
   && command -v krdict >/dev/null 2>&1 \
   && command -v korpora-search >/dev/null 2>&1; then
  exit 0
fi

# Nudge once, then stay quiet (don't nag every session).
[ -f "$MARK" ] && exit 0
mkdir -p "$(dirname "$MARK")" && touch "$MARK" 2>/dev/null || true

cat >&2 <<EOF
[jjakmal] CLI tools (kollocate / krdict / korpora-search) aren't on your PATH yet.
[jjakmal] One-time setup:  cd "$ROOT" && ./install.sh
[jjakmal] kollocate & korpora-search need no API key; krdict needs free NIKL keys (see README).
EOF
exit 0
