---
name: korean-fix
description: Apply naturalness fixes across a whole Korean document — rewrite flagged translationese into natural Korean section by section, preserving meaning, structure, numbers, and proper nouns, with key collocations verified by the CLIs. The "act on the audit" step.
---

Fix the translationese in this Korean document, **paper-wide**:

$ARGUMENTS

1. **Find.** Run the `/korean-audit` flow (or reuse a prior audit / `NATURALNESS_AUDIT.md` if given)
   to get the flagged spans and suggested fixes.
2. **Rewrite, section by section.** Turn each flagged span into natural Korean. **Hard rules:**
   - Preserve meaning, facts, numbers, proper nouns, citations, and all markdown/structure exactly.
   - Change only phrasing/collocation/style — never content.
   - Verify any non-obvious new collocation with `kollocate` / `krdict -x` before committing to it.
3. **Apply or propose:**
   - Default: apply the edits to the file(s) and report a per-section summary of what changed.
   - `--dry-run`: show a before/after diff per span and change nothing.
4. **Re-check.** Re-run `naturalness-reviewer` on the changed sections and report the before/after
   finding count, so the improvement is measured, not assumed.

If a fix would change meaning to "make it flow", do NOT apply it — leave the span and flag it for a
human instead. Natural ≠ rewritten-into-something-else.
