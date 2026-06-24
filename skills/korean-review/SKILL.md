---
name: korean-review
description: Use when reviewing Korean text for naturalness — collocation (연어) verification, dictionary lookup, corpus concordance evidence. Trigger when the user asks "이 표현 자연스러워?", "연어 맞아?", "한국어 어색해?", "collocation 검증", "표준어 맞아?", "번역투 점검", or during any Korean report/translation sweep. Provides three CLI tools — kollocate (연어), krdict (사전·용례), korpora-search (corpus) — that return objective evidence rather than guesses. Never answer Korean naturalness from intuition; call a tool, show the evidence, then conclude.
---

# korean-review — Korean text naturalness verification toolchain

> **Purpose**: LLMs are weak at Korean collocation/naturalness intuition. This skill replaces
> guesswork with objective corpus/dictionary evidence queried directly from the CLI.

## 0. When to use

Call at least one tool whenever any of these apply:

- The user questions a Korean expression, collocation, or 연어 ("이거 어색해?", "이런 표현 쓰여?", "X와 Y 같이 써?")
- Sweeping a Korean translation/report for suspect phrasing (translationese, calques)
- Checking canonical orthography / standard-term usage
- Verifying a neologism, technical term, or loanword spelling

**No intuition-only answers.** Always: call a tool → present the objective evidence → conclude.

## 1. The tools (4, all CLI)

After `./install.sh` they live on your `PATH`. `kollocate` and `korpora-search` need no API key;
`krdict` needs free per-dictionary NIKL keys (see §1.2.1).

### 1.0 ⭐ Collocation entry point — `krdict -x <단어>` (우리말샘 usage examples)

**The first-line collocation check — when a key is available.** It needs the free `KRDICT_URIMAL_KEY`;
if no key is set, fall back to `kollocate` (key-free) as the first-line and treat `krdict -x` as the
deeper follow-up. Pulls up to 30 real usage examples from 우리말샘 (`part=exam`)
and shows the query word with ±22 chars of surrounding context — a live, broad corpus that
complements Sejong's older (1998–2007) data. `뒷받침` → 162 examples, `활성화` → 795. See §2.

### 1.1 `kollocate <어간>` — collocation frequency (Sejong corpus)

**Input rules:**
- Verb/adjective: drop the ending (먹다 → `먹`, 활성화하다 → `활성화`)
- Noun: as-is (활성화, 뒷받침, 토대)

**Output:** target-word POS × collocate POS × (word, frequency) matrix.

```bash
$ kollocate 뒷받침 --top 5
=== '뒷받침' 연어 ===
[명사]
  ↳ 동사: 이르(9), 주(7), 있(7), 하(4), 되(3)
  ↳ 명사: 것(5), 증거(4), 이론(3), 주장(3), 이론적(3)
```
→ natural collocates of 뒷받침 are 증거/이론/주장/근거. "활성화를 뒷받침" is a weak pairing.

**Options:** `--top N` (per-POS top N, default 8), `--json` (raw).
**Source:** Sejong corpus (국립국어원), via the Kollocate package (Kyubyong Park).

### 1.2 `krdict <단어>` — 3 NIKL dictionaries (separate key per dictionary)

```bash
$ krdict 활성화                # 표준국어대사전 (default)
$ krdict -u 활성화             # 우리말샘 (neologisms, technical terms)
$ krdict -k 활성화             # 한국어기초사전 (learner: level + examples + 11-lang gloss) ⭐
$ krdict -a 활성화             # all three at once
$ krdict 활성화 --method include   # partial match
$ krdict 활성화 --pos 1            # nouns only (code 1)
```

**KBASE response fields:** target_code / word / 한자(origin) / pronunciation / word_grade
(초급·중급·고급) / pos / sense×N (definition + 11-language translation).

#### 1.2.1 API keys + environment variables

| Dictionary | Register at | Env var | Format |
|---|---|---|---|
| 표준국어대사전 | https://stdict.korean.go.kr/openapi/openApiInfo.do | `KRDICT_STDICT_KEY` | XML / JSON |
| 우리말샘 | https://opendict.korean.go.kr/service/openApiInfo | `KRDICT_URIMAL_KEY` | XML / JSON |
| 한국어기초사전 | https://krdict.korean.go.kr/openApi/openApiInfo | `KRDICT_KBASE_KEY` | **XML only** |

Each key is a **separate** registration — reusing one on another endpoint returns `error 020
Unregistered key`. KBASE requires a `User-Agent` header (the wrapper sets one). After issuing,
`export KRDICT_*_KEY=<32-hex>` in your shell rc.

**Rate limit (KBASE):** 50,000/day (over → `error 010`).
**Common errors:** 020 = unregistered key, 021 = suspended key, 100 = malformed query.

#### 1.2.2 Rich KBASE options (한국어기초사전 only)

Full tables in [`references/dict_apis_quickref.md`](references/dict_apis_quickref.md):

| Option | Values | Meaning |
|---|---|---|
| `sort` | `dict` / `popular` | dictionary order / most-searched |
| `part` | `word` / `ip` / `dfn` / `exam` | search target (lemma / idiom·proverb / definition / example) |
| `translated` + `trans_lang` | 0–11 | multilingual gloss (en, ja, fr, es, ar, mn, vi, th, id, ru, zh) |
| `level` | `level1`/`level2`/`level3` | beginner / intermediate / advanced vocabulary |
| `type1` | `word`/`phrase`/`expression` | word / phrase / grammatical expression |
| `type2` | `native`/`chinese`/`loanword`/`hybrid` | word origin |
| `pos` | 0–15 (comma-multi) | part of speech (1=noun, 5=verb, 6=adjective, …) |
| `sense_cat` | 0–153 | 154 semantic categories |
| `subject_cat` | 0–106 | 107 learning scenarios |

Full code tables (154 sense_cat · 107 subject_cat · POS · 11 languages) →
[`references/dict_apis_quickref.md`](references/dict_apis_quickref.md). Raw spec →
[`references/kbase_openapi.txt`](references/kbase_openapi.txt).

#### 1.2.3 Choosing a dictionary

- **표준국어대사전** → canonical standard-Korean meaning
- **우리말샘** → neologisms, dialect, technical/participatory terms
- **한국어기초사전** → learner examples, level grading, 11-language gloss ⭐

Review workflow:
1. `krdict -k <단어>` → definition + level (advanced/intermediate) + examples
2. If level is "advanced" but the context is everyday, suspect a register mismatch
3. `krdict -k <단어> --translated --trans-lang 1` → English gloss to map against the source word
   (`--trans-lang`: 1=en 2=ja 3=fr 4=es 5=ar 6=mn 7=vi 8=th 9=id 10=ru 11=zh)

### 1.3 `korpora-search <단어>` — corpus concordance

```bash
$ korpora-search 활성화 --corpus nsmc --limit 5
$ korpora-search --list
$ korpora-search --download korean_petitions
$ korpora-search 뒷받침 --corpus korean_petitions --limit 10
```

**Recommended corpora (naturalness work):**
- `nsmc` — NAVER movie reviews (colloquial, 200K)
- `korean_petitions` — Blue House petitions (formal) ⭐ fits policy/report review
- `kcbert` — comments (colloquial + informal)
- `kowikitext` — Korean Wikipedia (encyclopedic)
- `modu_news` — NIKL newspaper corpus (download after authentication)

Data lands in `~/Korpora/`.

### 1.4 Document sweep

For long documents, do a paragraph-level first pass (manually or with a sub-agent), flag suspect
spans, then strengthen each with the CLIs above. A reusable 9-pattern checklist:

1. Inanimate subject + English causative (X은 Y를 노출시킨다)
2. Calqued English abstract noun phrase (provide signal / open path)
3. Calqued English metaphor (올바른 방향으로 / 토대가 되다)
4. Residual English words (메커니즘 / 이니셔티브 where a Korean term exists)
5. Domain canonical-term violation (use the industry's standard term)
6. Cohesive "this" calque (본 X / 이러한 X overuse)
7. English sentence structure (X 함으로써 / 측면에서)
8. Telegraphic table-cell style
9. Domain accuracy (bill/notice numbers, ministry names, dates)

## 2. Standard collocation-verification flow ⭐

### 2.1 Primary evidence — `krdict -x <단어>` (우리말샘 examples)

The strongest single signal. `part=exam` pulls real usage:

```bash
$ krdict -x 뒷받침
[우리말샘 용례] total=162
  1. ...법적·제도적 뒷받침을 해야 한다...
  2. ...이론이 뒷받침되는 주장...
  3. ...실효성이 뒷받침되지 않는...
  ...
```

**Observed natural patterns (뒷받침):** `법적·제도적 / 법률에 의해` + 뒷받침 (means);
`이론·논거·증거` + 이/가 + 뒷받침 (argument support); `실효성·실적` + 이 + 뒷받침되다 (capacity);
`경제 성장·재정 운영` + 을 + 뒷받침하다 (institutional support).
→ 뒷받침하다 *does* take 을-objects (경제 성장을 뒷받침), but "활성화" is **not** among its attested
objects in these 162 examples. That is evidence to **flag and verify** (prefer an attested phrasing),
**not** proof of a calque — absence in a sample is weak evidence, so report the count, not a verdict.

### 2.2 Secondary — `kollocate <어간>` (Sejong frequency)

```bash
$ kollocate 뒷받침
[명사] ↳ 명사: 증거(4), 이론(3), 주장(3), 근거(2)
```

Cross-validate with the 우리말샘 examples. Agreement → strong verdict.

| Tool | Strength | Weakness |
|---|---|---|
| `krdict -x` (우리말샘) | live, broad corpus; shows real sentences; 162–795 examples | binary (present/absent), no frequency stats |
| `kollocate` (Sejong) | POS-tagged frequency ranking | older corpus (1998–2007); weak on domain terms |

### 2.3 Tertiary — `krdict -k <단어>` (level + definition)

Confirms register (초급/중급/고급) + learner definition + foreign-language gloss.

### 2.4 Quaternary — `korpora-search <단어>` (multi-register corpus)

`korean_petitions` (formal) / `nsmc` (colloquial) / `kowikitext` (encyclopedic) for register checks.

### 2.5 Final verdict

1. `krdict -x <핵심어>` — natural examples 0~few? (top priority)
2. `kollocate <어간>` — frequency cross-check
3. `krdict -k <단어>` — level/register
4. `korpora-search` — domain corpus presence (optional)
5. `krdict <단어>` (표준국어대사전) — strict canonical check (after key issued)

## 3. Reporting format (to the user)

```
Phrase: "활성화를 뒷받침한다"

[kollocate]
  뒷받침 → noun collocates: 증거(4), 이론(3), 주장(3), 근거(2)
  → no evidence of pairing with "활성화"

[krdict 표준국어대사전]
  뒷받침 (noun): support given from behind so that a task/claim succeeds

[korpora-search korean_petitions]
  "활성화" + "뒷받침" co-occurrence: 0
  "활성화" + "이어지다" / "촉진" / "도모": many

→ Read: "활성화" is unattested with 뒷받침 in these sources — flag and verify;
  consider an attested phrasing such as "활성화로 이어진다". (Evidence, not a verdict.)
```

## 4. Tool locations

| Tool | Path after install |
|---|---|
| kollocate | `bin/kollocate` → symlinked to `~/.local/bin/kollocate` |
| krdict | `bin/krdict` → `~/.local/bin/krdict` |
| korpora-search | `bin/korpora-search` → `~/.local/bin/korpora-search` |
| Kollocate (lib) | `pip install kollocate` |
| Korpora (lib) | `pip install Korpora` |
| NIKL corpora | `~/Korpora/` |

### 4.1 Bundled references

| Resource | Location |
|---|---|
| 3-dictionary quick reference ⭐ | [`references/dict_apis_quickref.md`](references/dict_apis_quickref.md) |
| Kollocate README | [`references/kollocate_README.md`](references/kollocate_README.md) |
| Korpora README (27 corpora) | [`references/korpora_README.md`](references/korpora_README.md) |
| 표준국어대사전 OpenAPI | [`references/stdict_openapi.txt`](references/stdict_openapi.txt) |
| 우리말샘 OpenAPI | [`references/urimal_openapi.txt`](references/urimal_openapi.txt) |
| 한국어기초사전 OpenAPI (154 sense_cat · 107 subject_cat) | [`references/kbase_openapi.txt`](references/kbase_openapi.txt) |

## 5. Limitations / cautions

- **Sejong corpus is 1998–2007** — weak on recent neologisms → supplement with 우리말샘 / `kcbert`.
- **`kollocate` needs stems** — a final ending yields 0 results.
- **API rate** — STDICT/우리말샘 have hourly limits per key (typically ample); KBASE 50,000/day.
- **MODU corpus** — separate authentication + download at corpus.korean.go.kr.
- **No LLM-intuition shortcuts** — always call a CLI for collocation judgments.
