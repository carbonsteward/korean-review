#!/usr/bin/env bash
# 번역투 회귀 가드 (translationese regression guard)
#
# 단순한 단어 blocklist다 — 실제 kollocate/krdict 엔진이 아니라 `grep -F`로,
# 이미 한 번 고친 명백한 직역 표기(예: 코퍼스, 엔드포인트)가 우리 문서에 되돌아오면
# CI를 실패시킨다. 자연성 판정을 하는 게 아니라, 같은 실수의 재발만 막는다.
#
# 스캔 대상은 '우리가 쓴' 한국어뿐 — 상위(upstream) references/ 와 영문 README,
# 그리고 패턴 단어가 들어 있는 이 스크립트 자신은 제외한다.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS=("$DIR/README.ko.md" "$DIR/.claude-plugin/plugin.json")

# "직역 표기|자연스러운 대안"
RULES=(
  "코퍼스|말뭉치"
  "엔드포인트|사전 / API"
  "당신이 쓴|사용자가 입력한 / 주어 생략"
  "당신의 키|사용자 본인 키"
  "근거 블록|근거 자료"
  "얇은 래퍼|가벼운 껍데기"
  "상위 도구|원본 도구"
  "상위 작업|원본 작업"
  "분위기가 아니라|막연한 느낌이 아니라"
  "병렬로 돕|동시에 검사"
  "정전 뜻풀이|표준 뜻풀이"
  "이게 전부입니다|설치는 이걸로 끝"
  "표식 파일|한 번 설치했다는 표시"
  "표시 파일|한 번 설치했다는 표시"
  "네 개 층|네 가지"
)

fail=0
for f in "${TARGETS[@]}"; do
  [ -f "$f" ] || continue
  for rule in "${RULES[@]}"; do
    pat="${rule%%|*}"; alt="${rule#*|}"
    if grep -nF -- "$pat" "$f" >/dev/null 2>&1; then
      echo "FAIL: '${pat}' 발견 → ${f##*/} (AI 번역투). 자연스러운 표현: ${alt}"
      grep -nF -- "$pat" "$f" | sed 's/^/    /'
      fail=1
    fi
  done
done

if [ "$fail" -eq 0 ]; then
  echo "OK: 우리 한국어 문서에 알려진 번역투 표기가 없습니다."
fi
exit "$fail"
