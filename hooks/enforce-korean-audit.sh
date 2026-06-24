#!/usr/bin/env bash
# OPT-IN Korean-draft reminder (PostToolUse on Write/Edit/MultiEdit).
#
# This is NOT auto-registered by the plugin — enable it yourself (see README:
# "Enforce an audit on every Korean draft"), so users who don't want it pay nothing.
#
# PostToolUse runs AFTER the write, so it CANNOT block the write — it only reminds the
# model (via additionalContext) to audit the draft, and drops a marker that the Stop
# hook (hooks/enforce-korean-stop.sh) uses for actual turn-end enforcement.
set -uo pipefail

MINLEN="${JJAKMAL_KOREAN_GATE_MINLEN:-20}"
payload="$(cat)"

SCRIPT=$(cat <<'PY'
import sys, json, re, os
minlen = int(sys.argv[1])
try: d = json.load(sys.stdin)
except Exception: sys.exit(0)
ti = d.get("tool_input") or {}
fp = ti.get("file_path") or "(the file)"
if "NATURALNESS_AUDIT" in os.path.basename(fp).upper():
    sys.exit(0)   # don't re-flag the audit's own report (would loop)
text = ti.get("content") or ti.get("new_string") or ""
if not text and isinstance(ti.get("edits"), list):
    text = "\n".join((e or {}).get("new_string", "") for e in ti["edits"])
hangul = len(re.findall(r"[가-힣]", text))
if hangul < minlen:
    sys.exit(0)
sid = d.get("session_id") or "default"
cdir = os.path.expanduser("~/.cache/jjakmal")
os.makedirs(cdir, exist_ok=True)
open(os.path.join(cdir, f"pending-{sid}"), "w").close()
blk = ["코퍼스", "엔드포인트", "근거 블록", "얇은 래퍼", "상위 도구", "병렬로 돕", "정전 뜻풀이"]
hits = [b for b in blk if b in text]
note = (" Quick check flagged: " + ", ".join(hits) + ".") if hits else ""
msg = (f"[jjakmal] A Korean draft ({hangul} Hangul chars) was written to {fp}. "
       f"Run `/korean-audit {fp}` to check it for translationese before finishing.{note}")
print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse",
                                          "additionalContext": msg}}, ensure_ascii=False))
PY
)
printf '%s' "$payload" | python3 -c "$SCRIPT" "$MINLEN"
