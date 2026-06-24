---
name: korean-review
description: Verify whether a Korean word/phrase/collocation is natural, using corpus + dictionary evidence. Returns a verdict with the actual tool output and a suggested fix.
---

The user wants a naturalness verdict on this Korean expression:

$ARGUMENTS

Follow the `korean-review` skill's verification flow. **Do not judge from intuition** — call the
CLI tools and quote their real output. The tools are on PATH after install (`kollocate` and
`korpora-search` need no API key; `krdict` needs free NIKL keys).

1. Identify the head word(s) and the specific collocation being questioned.
2. `krdict -x <head word>` — pull 우리말샘 usage examples; check whether the questioned pairing
   actually occurs, and how often.
3. `kollocate <stem>` — Sejong frequency cross-check (drop the `-다` ending for verbs/adjectives:
   먹다 → `먹`, 활성화하다 → `활성화`).
4. If register is in doubt, `krdict -k <word>` for the learner level (초급/중급/고급).
5. *(Optional)* `korpora-search <word> --corpus korean_petitions --limit 10` for formal-register
   concordance.

Then report exactly in this shape:

- **Phrase** — and what's being questioned about it
- **Evidence** — the actual tool output (quote real counts/examples, e.g. "0 of 162 examples")
- **Verdict** — natural / weak collocation / calque / register-mismatch
- **Fix** — a more natural alternative if needed, justified by the evidence above

If a needed tool reports a missing API key, say so plainly and continue with the key-free tools.
