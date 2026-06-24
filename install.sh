#!/usr/bin/env bash
# jjakmal — CLI runtime installer
#
# This installs the COMMAND-LINE part: the Python deps + the three CLI tools.
# The Claude plugin (skill + commands + agents) is best installed separately via:
#   /plugin marketplace add carbonsteward/jjakmal
#   /plugin install jjakmal@jjakmal
# The CLIs below are what those plugin components call, so install them regardless.
#
# - installs Python deps (kollocate, Korpora)
# - links the three CLI tools into a bin dir on your PATH
# - optionally links the Agent Skill into ~/.claude/skills (for non-plugin use)
#
# Usage:
#   ./install.sh                 # deps + link CLIs into ~/.local/bin
#   ./install.sh --skill         # also link the skill into ~/.claude/skills/korean-review
#   BIN_DIR=/usr/local/bin ./install.sh   # custom CLI target dir
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
LINK_SKILL=0
[[ "${1:-}" == "--skill" ]] && LINK_SKILL=1

# --gate: print a ready-to-paste settings.json snippet for the opt-in Korean-draft gate, then exit.
if [[ "${1:-}" == "--gate" ]]; then
  cat <<EOF
Add this to ~/.claude/settings.json to enforce a Korean-draft audit.
Both hooks = hard enforcement (turn won't end until /korean-audit runs).
PostToolUse only = non-blocking reminders. Remove the block to disable.

  "hooks": {
    "PostToolUse": [{ "matcher": "Write|Edit|MultiEdit",
      "hooks": [{ "type": "command", "command": "bash $REPO_DIR/hooks/enforce-korean-audit.sh" }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "bash $REPO_DIR/hooks/enforce-korean-stop.sh" }] }]
  }
EOF
  exit 0
fi

echo "==> jjakmal install"
echo "    repo:    $REPO_DIR"
echo "    bin dir: $BIN_DIR"

# 1. Python deps
echo "==> Installing Python dependencies (kollocate, Korpora)"
if command -v pip3 >/dev/null 2>&1; then
  pip3 install -r "$REPO_DIR/requirements.txt"
else
  echo "!! pip3 not found. Install Python 3.6+ and pip, then re-run." >&2
  exit 1
fi

# 2. Link CLIs
echo "==> Linking CLI tools into $BIN_DIR"
mkdir -p "$BIN_DIR"
for tool in kollocate krdict korpora-search; do
  ln -sf "$REPO_DIR/bin/$tool" "$BIN_DIR/$tool"
  chmod +x "$REPO_DIR/bin/$tool"
  echo "    linked $tool"
done

# 3. Optional: link the Agent Skill
if [[ "$LINK_SKILL" == "1" ]]; then
  SKILL_DST="$HOME/.claude/skills/korean-review"
  echo "==> Linking Agent Skill into $SKILL_DST"
  mkdir -p "$HOME/.claude/skills"
  ln -sfn "$REPO_DIR/skills/korean-review" "$SKILL_DST"
  echo "    linked (SKILL.md + references/ now visible to Claude)"
  echo "    (note: this only links the skill — for commands + agents, install the plugin instead)"
fi

# 4. PATH hint
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "!! $BIN_DIR is not on your PATH. Add to your shell rc:"
     echo "     export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

cat <<'EOF'

==> Done.

Next: set your NIKL dictionary API keys (free, one per dictionary) so `krdict`
works. The collocation tools (kollocate, korpora-search) need NO keys.

  export KRDICT_STDICT_KEY=...   # https://stdict.korean.go.kr/openapi/openApiInfo.do
  export KRDICT_URIMAL_KEY=...   # https://opendict.korean.go.kr/service/openApiInfo
  export KRDICT_KBASE_KEY=...    # https://krdict.korean.go.kr/openApi/openApiInfo

Quick test (no key needed):
  kollocate 뒷받침
  korpora-search 활성화 --download nsmc && korpora-search 활성화 --corpus nsmc --limit 3
EOF

# 5. Optional: offer to open the three key-registration pages (interactive shells only —
#    skipped when run non-interactively, e.g. by the plugin's SessionStart hook).
STDICT_SIGNUP="https://stdict.korean.go.kr/openapi/openApiInfo.do"
URIMAL_SIGNUP="https://opendict.korean.go.kr/service/openApiInfo"
KBASE_SIGNUP="https://krdict.korean.go.kr/openApi/openApiInfo"
if [ -t 0 ]; then
  printf '\nOpen the 3 NIKL key-registration pages in your browser now? [y/N] '
  read -r ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    if command -v open >/dev/null 2>&1; then opener=open          # macOS
    elif command -v xdg-open >/dev/null 2>&1; then opener=xdg-open # Linux
    else opener=""; fi
    if [ -n "$opener" ]; then
      "$opener" "$KBASE_SIGNUP" "$URIMAL_SIGNUP" "$STDICT_SIGNUP" >/dev/null 2>&1 || true
      echo "Opened. Register on each, copy the 32-hex key, and export KRDICT_*_KEY in your shell rc."
    else
      echo "No browser opener found. Visit the URLs above manually."
    fi
  fi
fi
