---
name: korean-compare
description: Compare two Korean phrasings and pick the more natural one, with corpus/dictionary evidence for both candidates.
---

Compare these Korean phrasings and decide which is more natural:

$ARGUMENTS

The user gives two candidates, usually as "A vs B" or "A / B". For **each** candidate, gather
evidence — never decide from intuition:

1. `krdict -x <head word>` — does the candidate's pairing occur in 우리말샘 examples? how often?
2. `kollocate <stem>` — Sejong collocation frequency (drop the `-다` ending for verbs/adjectives).

Then:

- Show a **side-by-side evidence block** (real counts/examples for both candidates).
- Declare a **winner**, or "both acceptable" with the nuance (register or frequency difference).
- If a **third** phrasing is clearly more natural than both, offer it — with its own evidence.

The verdict must rest on the tool output, not on intuition. If `krdict` lacks a key, proceed with
`kollocate` (and `korpora-search` if helpful) and say the dictionary check was skipped.
