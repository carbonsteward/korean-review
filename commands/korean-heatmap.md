---
name: korean-heatmap
description: Translationese triage for a whole paper — score each section/chapter by how machine-translated it reads and rank them so you know where to focus editing first. A fast diagnostic, not a fix or a full audit.
---

Score this Korean document (or directory) section by section for translationese density:

$ARGUMENTS

Goal: tell the editor **where** the problems concentrate before diving in.

1. **Segment** by section/chapter (by heading; for a directory, per file).
2. **Score each section.** Dispatch `naturalness-reviewer` across the sections **in parallel** to
   flag spans. Compute a density score = `(HIGH×3 + MED×1) per ~1000 characters`, so long and short
   sections compare fairly.
3. **Rank worst → best** and output a heatmap table:
   `section | length | score | HIGH | MED | top 2 patterns here` with a cue per row
   (🔴 heavy / 🟡 some / 🟢 clean).
4. **Conclude:** the 3 sections to edit first, and whether the whole paper reads machine-translated
   or only spots do.

Triage only — no rewriting and no per-span CLI verification (use `/korean-audit` for evidence-backed
findings, `/korean-fix` to rewrite). Keep it fast.

> Honesty: the score comes from the `naturalness-reviewer`'s flags, which are LLM judgment, not
> tool-verified counts — so it's a **relative, indicative** ranking (run twice, expect small
> differences), not a precise metric. Use it to prioritize, not to grade.
