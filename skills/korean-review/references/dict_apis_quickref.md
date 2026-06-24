---
title: 국립국어원 3 사전 OpenAPI quick reference
sources:
  - 표준국어대사전 (stdict.korean.go.kr/openapi/openApiInfo.do)
  - 우리말샘 (opendict.korean.go.kr/service/openApiInfo)
  - 한국어기초사전 (krdict.korean.go.kr/kor/openApi/openApiInfo)
last_verified: 2026-05-26
---

# 국립국어원 3 사전 OpenAPI 통합 가이드

각 사전은 **별도 인증키** 필요. 단일 키로 3 사전 모두 사용 불가.

## 0. 사전 비교

| 사전 | URL | 키 발급처 | 응답 형식 | 특징 |
|---|---|---|---|---|
| **표준국어대사전** | stdict.korean.go.kr | https://stdict.korean.go.kr → 회원가입 → 인증키신청 | XML / JSON | 표준어 정전 |
| **우리말샘** | opendict.korean.go.kr | https://opendict.korean.go.kr → 인증키 신청 | XML / JSON | 신조어·방언·전문용어 |
| **한국어기초사전** | krdict.korean.go.kr | https://krdict.korean.go.kr → 인증키 신청 | XML only | 학습자용, 11개 언어 번역·등급 |

**호출 limit:**
- 표준국어대사전 / 우리말샘: 명시되지 않음 (정전 응답에 limit 없음)
- 한국어기초사전: **50,000 회/일** (error 010 발생 시 quota 초과)

**error code 공통:**
- 020: Unregistered key (미등록)
- 021: 일시 중지된 키
- 100: 부적절한 쿼리
- 010: 일일 한도 초과 (KBASE)

---

## 1. 표준국어대사전 API

**Endpoints**:
- 검색: `https://stdict.korean.go.kr/api/search.do`
- 조회: `https://stdict.korean.go.kr/api/view.do`

**Request parameters**:

| param | 타입 | 허용값 | 필수 | 설명 |
|---|---|---|---|---|
| `key` | string | 16진수 32자리 | ✅ | 인증키 |
| `q` | string | UTF-8 | ✅ | 검색어 |
| `req_type` | string | xml / json | 선택 | 기본 xml |
| `start` | int | 1~1000 | 선택 | 기본 1 |
| `num` | int | 10~100 | 선택 | 기본 10 |
| `advanced` | string | y / n | 선택 | 자세히 찾기 |
| `method` | string | exact / include / start / end / wildcard | 선택 | 기본 exact |
| `type1` | string | word / phrase / idiom / proverb | 선택 | 단어 구분 |
| `type2` | string | native / chinese / loanword / hybrid | 선택 | 어종 |
| `pos` | int array | 0~15 (콤마 다중) | 선택 | 품사 |
| `cat` | int array | 0~67 (콤마 다중) | 선택 | 전문분야 |

**Response (XML)**:
```xml
<channel>
  <total>N</total>
  <item>
    <word>활성화</word>
    <pos>명사</pos>
    <sense>
      <sense_no>1</sense_no>
      <definition>...</definition>
      <example>...</example>
    </sense>
  </item>
</channel>
```

---

## 2. 우리말샘 API

**Endpoints**:
- 검색: `https://opendict.korean.go.kr/api/search`
- 조회: `https://opendict.korean.go.kr/api/view`

**Request parameters** (STDICT 대비 추가):

| param | 타입 | 허용값 | 설명 |
|---|---|---|---|
| `part` | string | word / exam | 검색 대상 (어휘 / 용례) |
| `target` | int | 1~10 | 표제어·뜻풀이·용례 등 |
| `pos` | int array | 0~27 | 표준보다 더 많은 품사 코드 |
| `cat` | int array | 0~67 | 전문분야 |
| `multimedia` | int array | 0~6 | 사진·삽화·동영상 등 |
| `letter_s` / `letter_e` | int | 음절 수 시작/끝 | |
| `sense_cat` | int array | 의미 범주 |
| `type1` | string | word/phrase/idiom/proverb |
| `type2` | string | native/chinese/loanword/hybrid |
| `update_s` / `update_e` | YYYY-MM-DD | 갱신일 |

**Response 구조**: STDICT 와 유사 + `cat` (전문분야), `pos` 더 다양.

---

## 3. 한국어기초사전 API ⭐ (사용자 발급 완료)

**Endpoints**:
- 검색: `https://krdict.korean.go.kr/api/search`
- 조회: `https://krdict.korean.go.kr/api/view`

**중요**: User-Agent 헤더 필요. curl 시 `-A "Mozilla/5.0"` 필수. 응답은 XML only (req_type=json 미지원).

**Request parameters 전체 (공식 docs 기반)**:

| param | 타입 | 허용값 | 필수 | 설명 |
|---|---|---|---|---|
| `key` | string | 16진수 32자리 | ✅ | 인증키 |
| `q` | string | UTF-8 | ✅ | 검색어 |
| `start` | int | 1~1000 | 선택 | 기본 1 |
| `num` | int | 10~100 | 선택 | 기본 10 |
| `sort` | string | `dict` / `popular` | 선택 | 사전순 / 많이 찾은 순 |
| `part` | string | `word` / `ip` / `dfn` / `exam` | 선택 | 어휘 / 관용구·속담 / 뜻풀이 / 용례 |
| `translated` | string | `y` / `n` | 선택 | 다국어 번역 활성 |
| `trans_lang` | string | 0~11 (콤마 다중) | 선택 | 번역 언어 (`translated=y` 일 때) |
| `advanced` | string | `y` / `n` | 선택 | 자세히 찾기 |
| `target` | int | 1~10 | 선택 (advanced=y) | 찾을 대상 |
| `lang` | int | 0~49 | 선택 (target=4 원어) | 언어 (49개) |
| `method` | string | `exact` / `include` / `start` / `end` | 선택 | 기본 exact |
| `type1` | string array | `all` / `word` / `phrase` / `expression` | 선택 | 단어 / 구 / 문법 표현 |
| `type2` | string array | `all` / `native` / `chinese` / `loanword` / `hybrid` | 선택 | 어종 |
| `level` | string array | `all` / `level1` / `level2` / `level3` | 선택 | **초급 / 중급 / 고급** |
| `pos` | int array | 0~15 (콤마 다중) | 선택 | 품사 |
| `multimedia` | int array | 0~6 (콤마 다중) | 선택 | 다중 매체 |
| `letter_s` / `letter_e` | int | 음절 수 시작/끝 | 선택 | |
| `sense_cat` | int array | 0~153 | 선택 | **154 의미 범주** |
| `subject_cat` | int array | 0~106 | 선택 | **107 주제 및 상황 범주** |

### 3.1 trans_lang 코드표 (11 언어)

| 코드 | 언어 | 코드 | 언어 |
|---|---|---|---|
| 0 | 전체 | 6 | 몽골어 |
| 1 | 영어 | 7 | 베트남어 |
| 2 | 일본어 | 8 | 타이어 |
| 3 | 프랑스어 | 9 | 인도네시아어 |
| 4 | 스페인어 | 10 | 러시아어 |
| 5 | 아랍어 | 11 | 중국어 |

### 3.2 target 코드 (advanced=y 시)

| 코드 | 대상 |
|---|---|
| 1 | 어휘(표제어) — 기본 |
| 2 | 뜻풀이 |
| 3 | 용례 |
| 4 | 원어 (한자·외국어, `lang` 옵션 가능) |
| 5 | 발음 |
| 6 | 활용 |
| 7 | 활용의 준말 |
| 8 | 관용구 |
| 9 | 속담 |
| 10 | 참고 정보 |

### 3.3 lang 코드 (target=4 원어 검색 시, 49 언어)

```
0=전체, 1=고유어, 2=한자, 3=안 밝힘, 4=영어, 5=그리스어, 6=네덜란드어, ...
30=일본어, 31=중국어, 42=프랑스어, ...
```
(전체 49개는 raw kbase_openapi.txt 라인 156-160 참조)

### 3.4 pos 코드 (16 품사)

| 코드 | 품사 | 코드 | 품사 |
|---|---|---|---|
| 0 | 전체 | 8 | 부사 |
| 1 | 명사 | 9 | 감탄사 |
| 2 | 대명사 | 10 | 접사 |
| 3 | 수사 | 11 | 의존 명사 |
| 4 | 조사 | 12 | 보조 동사 |
| 5 | 동사 | 13 | 보조 형용사 |
| 6 | 형용사 | 14 | 어미 |
| 7 | 관형사 | 15 | 품사 없음 |

### 3.5 sense_cat (154 의미 범주) — 대분류

```
인간(1-17), 삶(18-30), 식생활(31-41), 의생활(42-50), 주생활(51-59),
사회 생활(60-76), 경제 생활(77-83), 교육(84-92), 종교(93-100),
문화(101-110), 정치와 행정(111-118), 자연(119-125), 동식물(126-133),
개념(134-153)
```
(전체 154 세분류는 raw docs 참조)

### 3.6 subject_cat (107 주제 및 상황 범주) — 학습 시나리오

```
인사하기(1), 소개하기(2-3), 위치 표현(5), 길찾기(6), 음식 주문(9),
요리 설명(10), 시간/날짜/요일/날씨(11-14), 학교/한국생활(16-17),
약속·전화·감사·사과(18-21), 여행·취미·건강(22-26), 공공기관 이용(29-31),
직업과 진로(49), 환경 문제(69, 92), 인간관계(71, 95),
역사·정치·종교·철학(103-106)
```
(전체 107 항목은 raw docs 참조)

### 3.7 Response (XML)

```xml
<channel>
  <title>한국어 기초사전 개발 지원(Open API) - 사전 검색</title>
  <total>3</total>
  <start>1</start>
  <num>10</num>
  <item>
    <target_code>87098</target_code>
    <word>활성화</word>
    <sup_no>0</sup_no>
    <origin>活性化</origin>             <!-- 한자 등 원어 -->
    <pronunciation>활썽화</pronunciation>
    <word_grade>고급</word_grade>      <!-- 초급/중급/고급 -->
    <pos>명사</pos>
    <link>https://krdict.korean.go.kr/kor/dicSearch/SearchView?ParaWordNo=...</link>
    <sense>
      <sense_order>1</sense_order>
      <definition>사회나 조직 등의 기능이 활발함. 또는 그러한 기능을 활발하게 함.</definition>
      <translation>                    <!-- translated=y 일 때 -->
        <trans_lang>영어</trans_lang>
        <trans_word>activation</trans_word>
        <trans_dfn>...</trans_dfn>
      </translation>
    </sense>
  </item>
</channel>
```

### 3.8 예시 query

```bash
# 기본 검색
curl -sSL -A "Mozilla/5.0" -G \
  --data-urlencode "key=$KRDICT_KBASE_KEY" \
  --data-urlencode "q=활성화" \
  "https://krdict.korean.go.kr/api/search"

# 초급 어휘만 검색 + 영어 번역 포함
curl -sSL -A "Mozilla/5.0" -G \
  --data-urlencode "key=$KRDICT_KBASE_KEY" \
  --data-urlencode "q=활성화" \
  --data-urlencode "level=level1" \
  --data-urlencode "advanced=y" \
  --data-urlencode "translated=y" \
  --data-urlencode "trans_lang=1" \
  "https://krdict.korean.go.kr/api/search"

# 용례에서 단어 검색 + 사용 빈도 정렬
curl -sSL -A "Mozilla/5.0" -G \
  --data-urlencode "key=$KRDICT_KBASE_KEY" \
  --data-urlencode "q=활성화" \
  --data-urlencode "part=exam" \
  --data-urlencode "sort=popular" \
  "https://krdict.korean.go.kr/api/search"
```

---

## 4. krdict CLI 의 옵션 → API parameter 매핑

| CLI 옵션 | API param | 사전 |
|---|---|---|
| `<word>` | `q` | 모두 |
| `--method exact/include/start/end/wildcard` | `method` | 모두 |
| `--num N` | `num` | 모두 |
| `--start N` | `start` | 모두 |
| `--pos N` | `pos` | 모두 |
| `-u` | (URIMAL endpoint) | URIMAL |
| `-k` | (KBASE endpoint + UA 헤더) | KBASE |
| `-a` | (3 endpoint 동시) | ALL |
| `--raw` | 원본 XML/JSON 출력 | 모두 |

### 향후 개선 후보 (KBASE 풍부 옵션 활용)

- `--level level1/level2/level3` → KBASE 등급 필터
- `--sort popular` → 많이 찾은 순
- `--part word/ip/dfn/exam` → 검색 대상
- `--translated y --trans-lang 1` → 영어 번역 포함
- `--sense-cat 7` → 의미 범주 (감정)
- `--subject-cat 49` → 학습 시나리오 (직업과 진로)
- `--target 2` (advanced=y) → 뜻풀이에서 검색

위 옵션은 v0.3 으로 별도 enhancement (현재 v0.2 는 기본 옵션만).
