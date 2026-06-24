---
name: korean-audit
description: Full-document Korean naturalness audit — fan out across the whole paper, flag translationese by the 9-pattern taxonomy, verify high-severity findings with corpus/dictionary evidence, and produce one consolidated, severity-ranked editorial report. Works on a single file or a whole directory of chapters.
---

Audit this Korean document (or directory) for naturalness, **paper-wide**:

$ARGUMENTS

The unit of work is the whole paper, not a sentence. If a directory or several files are given,
treat them as one report (sections/chapters).

1. **Gather & segment.** Read the file(s). Split into sections (by heading) and paragraphs. Ignore
   code blocks, data tables, URLs, and English text.
2. **Flag in parallel.** Dispatch the `naturalness-reviewer` subagent across the sections — one per
   section (batch small ones), **in parallel** — to flag suspect spans against the 9-pattern
   checklist. Keep each finding's section location.
3. **Verify the worst.** For each HIGH-severity span, dispatch `collocation-verifier` (in parallel)
   to attach CLI evidence (`kollocate` / `krdict -x` / `korpora-search`) and a concrete fix.
4. **Consolidate into ONE report** — write `NATURALNESS_AUDIT.md` next to the input (or print if the
   document is short):
   - **Verdict:** how machine-translated the paper reads (1–2 lines) + counts by severity.
   - **Findings table:** `section | span | pattern | severity | evidence | suggested fix`.
   - **Per-section breakdown:** counts per section so the editor sees where issues cluster.
   - **Systemic patterns:** the 2–3 problems that recur across the whole paper (e.g. "X 함으로써
     overused in 12 places"), since those are worth a global fix.
   - **Apply-first list:** the highest-leverage fixes.

5. **Release the gate.** When the audit is written, clear the enforcement marker (if the opt-in gate
   is enabled) so it knows this draft was audited:
   `rm -f "$HOME/.cache/jjakmal/"pending-* 2>/dev/null`

`--quick` = step 2 only (flags, no CLI verification) for a fast first pass. Default is thorough.
Never judge naturalness from intuition — every HIGH claim cites tool output.
