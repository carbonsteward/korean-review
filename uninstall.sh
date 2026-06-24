#!/usr/bin/env bash
# 짝말 / jjakmal — CLI uninstaller (mirror of install.sh)
#
# Removes the CLI symlinks, the optional skill link, and the bootstrap marker.
# Leaves the Python packages (kollocate, Korpora) installed, since they may be
# shared with other tools — remove them yourself if you want:
#   pip uninstall kollocate Korpora
#
# Usage:
#   ./uninstall.sh
#   BIN_DIR=/usr/local/bin ./uninstall.sh   # if you installed elsewhere
set -euo pipefail

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
echo "==> 짝말 uninstall (bin dir: $BIN_DIR)"

for tool in kollocate krdict korpora-search; do
  if [ -L "$BIN_DIR/$tool" ] || [ -e "$BIN_DIR/$tool" ]; then
    rm -f "$BIN_DIR/$tool"
    echo "    removed $BIN_DIR/$tool"
  fi
done

SKILL_DST="$HOME/.claude/skills/korean-review"
if [ -L "$SKILL_DST" ]; then
  rm -f "$SKILL_DST"
  echo "    removed skill link $SKILL_DST"
fi

MARK="$HOME/.cache/jjakmal/.cli-nudge-shown"
if [ -f "$MARK" ]; then
  rm -f "$MARK"
  rmdir "$HOME/.cache/jjakmal" 2>/dev/null || true
  echo "    cleared nudge marker"
fi

cat <<'EOF'

==> Done. CLI symlinks removed.

The Python packages (kollocate, Korpora) were left installed in case other
tools use them. Remove them yourself if unused:
    pip uninstall kollocate Korpora

If you installed the Claude plugin, also run inside Claude Code:
    /plugin uninstall jjakmal
    /plugin marketplace remove jjakmal
EOF
