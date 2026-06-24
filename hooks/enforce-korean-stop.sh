#!/usr/bin/env bash
# OPT-IN hard enforcement (Stop hook) — pair with enforce-korean-audit.sh.
#
# NOT auto-registered by the plugin. Enable it in your own ~/.claude/settings.json
# (see README). Unlike PostToolUse, a Stop hook CAN block — so if a Korean draft was
# written this turn and /korean-audit hasn't cleared the marker, this stops the turn
# from ending until the audit runs. The stop_hook_active guard prevents an infinite loop.
set -uo pipefail

payload="$(cat)"

SCRIPT=$(cat <<'PY'
import sys, json, os
try: d = json.load(sys.stdin)
except Exception: sys.exit(0)
if d.get("stop_hook_active"):       # already inside a stop-block cycle — don't loop
    sys.exit(0)
sid = d.get("session_id") or "default"
marker = os.path.expanduser(f"~/.cache/jjakmal/pending-{sid}")
if os.path.exists(marker):
    reason = ("A Korean draft was written this turn but `/korean-audit` hasn't run yet. "
              "Run `/korean-audit` on it now — that audits the draft and clears this gate — "
              "then finish. (To disable: remove the jjakmal Stop hook from your settings.json.)")
    print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))
PY
)
printf '%s' "$payload" | python3 -c "$SCRIPT"
