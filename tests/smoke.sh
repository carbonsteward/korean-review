#!/usr/bin/env bash
# Key-free smoke test: kollocate must return a known collocate for a known word.
# Requires `pip install -r requirements.txt` (kollocate) first.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

out="$("$DIR/bin/kollocate" 뒷받침 --top 3)"
echo "$out"
echo "---"
if echo "$out" | grep -q "증거"; then
  echo "PASS: kollocate returned expected collocate (증거) for 뒷받침"
else
  echo "FAIL: expected '증거' among 뒷받침 collocates" >&2
  exit 1
fi

# korpora-search: --list works offline (no key, no download)
if "$DIR/bin/korpora-search" --list | grep -q "nsmc"; then
  echo "PASS: korpora-search --list returned the corpus catalogue"
else
  echo "FAIL: korpora-search --list did not list nsmc" >&2
  exit 1
fi

# krdict: the documented flags exist (guards the past flag-crash bug without needing a key)
khelp="$("$DIR/bin/krdict" --help 2>&1)"
for f in --translated --trans-lang -k -x; do
  echo "$khelp" | grep -q -- "$f" || { echo "FAIL: krdict missing documented flag $f" >&2; exit 1; }
done
echo "PASS: krdict exposes its documented flags"
