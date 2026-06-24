---
name: korean-glossary
description: Paper-wide terminology audit — extract a document's recurring domain terms, flag the same concept translated inconsistently across sections, check each against canonical (정전) usage and natural collocations, and produce a unified-term recommendation table. For long reports where one English term gets rendered several different ways.
---

Audit terminology **consistency and canon** across this whole Korean document (or directory):

$ARGUMENTS

Goal is paper-wide term unification, not a single word.

1. **Extract recurring terms.** Read the file(s). Find domain terms / noun-phrases that recur
   (appear 2+ times), especially translated technical terms. Group likely-same-concept variants —
   e.g. one concept rendered three different ways in different sections.
2. **Gather evidence per term/group** (cite output, never intuition):
   - `krdict <term>` and `krdict -u <term>` — is it a standard/canonical headword?
   - `korpora-search <term> --corpus korean_petitions` (and a news corpus) — which variant actually
     appears in formal Korean?
   - `kollocate <stem>` — its natural collocations.
3. **Detect inconsistency.** Flag (a) concepts translated differently across sections, and
   (b) non-canonical terms where a standard one exists.
4. **Unified-term table:**
   `concept | variants found (+ where) | recommended canonical term | evidence | sections to change`
   End with: the top inconsistencies to unify first, and any non-canonical terms to replace.

If the document supplies its own glossary/term list, audit those terms directly instead of
extracting. Recommend one canonical term per concept, backed by dictionary/corpus evidence.

> Honesty: extraction and "same concept used inconsistently" are **your** reading of the document —
> no CLI detects cross-section consistency. Only the **canonical-term recommendation** is tool-backed
> (dictionary/corpus). Present the consistency findings as judgment, the canon as evidence.
