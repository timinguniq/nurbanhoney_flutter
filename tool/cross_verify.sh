#!/usr/bin/env bash
# 반대편 에이전트 도구로 교차 검증을 실행한다.
#   bash tool/cross_verify.sh <codex|claude> <역할> [추가 지시]
#
# 역할 정의: docs/agents/<역할>.md (verifier, code-reviewer, mutation-verifier)
# 검증은 tool/verify_copy.sh 로 만든 임시 복제본에서 돈다. 원본 작업 트리는 실행 전후 지문을
# 비교해 바뀌지 않았는지 확인한다. 결과는 .harness/reports/ 에 남는다(gitignore 대상).
#
# 종료 코드: 0 = 판정 PASS 이고 원본 무결성 유지.
#            1 = 판정 FAIL, 판정 없음, CLI 없음·실행 실패(인증·사용량 제한 포함), 원본 변경.
#            실행하지 못한 검증은 통과로 보지 않는다.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TOOL="${1:-}"
ROLE="${2:-}"
EXTRA="${3:-}"

usage() { echo "usage: bash tool/cross_verify.sh <codex|claude> <역할> [추가 지시]" >&2; exit 2; }
case "$TOOL" in codex|claude) ;; *) usage ;; esac
[ -n "$ROLE" ] || usage
ROLE_DOC="docs/agents/$ROLE.md"
[ -f "$ROOT/$ROLE_DOC" ] || { echo "[cross-verify] ✗ 역할 문서가 없습니다: $ROLE_DOC" >&2; exit 2; }

REPORT_DIR="$ROOT/.harness/reports"
mkdir -p "$REPORT_DIR" || exit 1
REPORT="$REPORT_DIR/$(date +%Y%m%d-%H%M%S)-$TOOL-$ROLE.md"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/cross_verify.XXXXXX")" || exit 1
COPY="$WORK/repo"
OUTPUT="$WORK/output.txt"
CLI_LOG="$WORK/cli.log"
trap 'rm -rf "$WORK"' EXIT

fingerprint() {
  git -C "$ROOT" rev-parse -q --verify HEAD || echo "(HEAD 없음)"
  git -C "$ROOT" status --porcelain=v1 -uall
  git -C "$ROOT" diff HEAD --binary | git hash-object --stdin
  git -C "$ROOT" diff --cached --binary | git hash-object --stdin  # staged 내용만 바뀌는 경우
  git -C "$ROOT" ls-files --others --exclude-standard -z | while IFS= read -r -d '' file; do
    printf '%s %s\n' "$(git hash-object -- "$ROOT/$file")" "$file"
  done
  # .worktreeinclude 의 secret 은 gitignore 대상이라 git status 에 나오지 않으므로 내용 해시를 따로 넣는다.
  [ -f "$ROOT/.worktreeinclude" ] || return 0
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    case "$pattern" in ""|\#*) continue ;; esac
    for source in "$ROOT"/${pattern#/}; do
      [ -e "$source" ] || continue
      find -L "$source" -type f | LC_ALL=C sort | while IFS= read -r file; do
        printf '%s %s\n' "$(git hash-object -- "$file")" "${file#"$ROOT"/}"
      done
    done
  done <"$ROOT/.worktreeinclude"
}

# 보고서를 쓰고 요약을 출력한 뒤 종료한다. 인자: 종료 코드, 판정, 비고, 원본 무결성
finish() {
  local code="$1" verdict="$2" note="$3" integrity="$4"
  {
    echo "# 교차 검증 보고서"
    echo
    echo "- 시각: $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo "- 검증 도구: $TOOL"
    echo "- 역할: $ROLE ($ROLE_DOC)"
    echo "- 원본: $ROOT"
    echo "- 원본 HEAD: $(git -C "$ROOT" rev-parse -q --verify HEAD || echo '(없음)')"
    echo "- 판정: $verdict"
    echo "- 원본 무결성: $integrity"
    echo "- 비고: $note"
    [ -z "$EXTRA" ] || echo "- 추가 지시: $EXTRA"
    echo
    echo "## 검증 도구 출력"
    echo
    echo '```text'
    [ -s "$OUTPUT" ] && cat "$OUTPUT" || echo "(출력 없음)"
    echo '```'
    if [ -s "$CLI_LOG" ]; then
      echo
      echo "## CLI 로그 (마지막 80줄)"
      echo
      echo '```text'
      tail -n 80 "$CLI_LOG"
      echo '```'
    fi
  } >"$REPORT"
  echo "[cross-verify] $TOOL/$ROLE → 판정: $verdict, 원본 무결성: $integrity ($note)"
  echo "[cross-verify] 보고서: $REPORT"
  exit "$code"
}

BEFORE="$(fingerprint)"

if ! command -v "$TOOL" >/dev/null 2>&1; then
  finish 1 "미실행" "'$TOOL' CLI 를 PATH 에서 찾을 수 없습니다." "확인 안 함"
fi

# 검증 도구에는 실제 secret 을 넘기지 않는다(복제본에는 CI 와 같은 더미 값).
if ! bash "$ROOT/tool/verify_copy.sh" --stub-secrets "$COPY" >"$CLI_LOG" 2>&1; then
  finish 1 "미실행" "검증용 복제본을 만들지 못했습니다." "확인 안 함"
fi
: >"$CLI_LOG"

PROMPT="$(cat "$ROOT/$ROLE_DOC")

---
실행 맥락 (tool/cross_verify.sh 가 덧붙임)
- 너는 다른 에이전트 도구가 만든 변경을 교차 검증한다. 위 역할 문서의 절차와 출력 형식을 따른다.
- 현재 디렉터리는 원본 작업 트리의 임시 복제본이다. HEAD 에 커밋되지 않은 변경이 모두 staged 로
  적용되어 있으므로, 검토할 변경은 'git diff --cached' 와 'git status' 로 본다.
- gitignore 대상 secret 은 CI 와 같은 더미 값이다(tool/ci/stub_secrets.sh). 실제 키가 필요한 동작은 검증 범위 밖이다.
- 원본 경로($ROOT)는 읽거나 수정하지 않는다. 복제본 밖의 파일을 바꾸지 않는다.
- 요청자의 추가 지시: ${EXTRA:-(없음)}
- 출력의 마지막 줄은 반드시 'VERDICT: PASS' 또는 'VERDICT: FAIL' 이다."

# Codex workspace-write 샌드박스는 작업 디렉터리 밖 쓰기와 네트워크를 막는다.
# - flutter 는 실행할 때마다 SDK 의 bin/cache 에 engine.stamp 를 쓰고, pub·analyze 는 사용자 캐시에 쓴다.
#   그 경로만 쓰기를 허용한다.
# - flutter test 는 127.0.0.1 에 서버 소켓을 열어야 하므로 네트워크를 허용한다. 복제본의 secret 은 더미 값이다.
CODEX_SANDBOX_ARGS=(-c sandbox_workspace_write.network_access=true)
if flutter_bin="$(command -v flutter)"; then
  flutter_root="$(python3 -c 'import os, sys; print(os.path.dirname(os.path.dirname(os.path.realpath(sys.argv[1]))))' "$flutter_bin")"
  for dir in "$flutter_root/bin/cache" "${PUB_CACHE:-$HOME/.pub-cache}" "$HOME/.dartServer" "$HOME/.dart-tool" \
             "$HOME/.flutter" "$HOME/.config/flutter" "$HOME/Library/Application Support/dart"; do
    [ -d "$dir" ] && CODEX_SANDBOX_ARGS+=(--add-dir "$dir")
  done
fi

# 두 CLI 모두 표준 입력이 터미널이 아니면 EOF 까지 읽는다. 열린 입력을 물려받으면 끝없이 기다리므로 막아 둔다.
run_cli() {
  cd "$COPY" || return 1
  case "$TOOL" in
    codex)
      exec codex exec -C "$COPY" -s workspace-write --skip-git-repo-check \
        ${CODEX_SANDBOX_ARGS[@]+"${CODEX_SANDBOX_ARGS[@]}"} -o "$OUTPUT" "$PROMPT" </dev/null >"$CLI_LOG" 2>&1
      ;;
    claude)
      exec claude -p "$PROMPT" --permission-mode acceptEdits \
        --allowedTools "Read" "Grep" "Glob" "Edit" "Write" \
        "Bash(flutter *)" "Bash(dart *)" "Bash(python3 *)" "Bash(bash tool/*)" \
        "Bash(git diff *)" "Bash(git status *)" "Bash(git log *)" "Bash(git show *)" \
        "Bash(cp *)" "Bash(ls *)" "Bash(cat *)" "Bash(grep *)" </dev/null >"$OUTPUT" 2>"$CLI_LOG"
      ;;
  esac
}

# 검증 도구가 멈춰도 끝나도록 시간 제한을 둔다. 시간 초과는 종료 코드 124 로 돌려준다.
TIMEOUT_SECONDS="${CROSS_VERIFY_TIMEOUT:-1800}"
run_cli &
CLI_PID=$!
waited=0
CLI_RC=""
while kill -0 "$CLI_PID" 2>/dev/null; do
  if [ "$waited" -ge "$TIMEOUT_SECONDS" ]; then
    # 먼저 TERM 으로 정리할 기회를 주고, 5초 안에 끝나지 않으면 KILL 한다(TERM 을 무시하는 경우).
    pkill -TERM -P "$CLI_PID" 2>/dev/null
    kill -TERM "$CLI_PID" 2>/dev/null
    grace=0
    while kill -0 "$CLI_PID" 2>/dev/null && [ "$grace" -lt 5 ]; do
      sleep 1
      grace=$((grace + 1))
    done
    pkill -KILL -P "$CLI_PID" 2>/dev/null
    kill -KILL "$CLI_PID" 2>/dev/null
    wait "$CLI_PID" 2>/dev/null
    CLI_RC=124
    break
  fi
  sleep 1
  waited=$((waited + 1))
done
if [ -z "$CLI_RC" ]; then
  wait "$CLI_PID"
  CLI_RC=$?
fi

AFTER="$(fingerprint)"
INTEGRITY="유지"
[ "$BEFORE" = "$AFTER" ] || INTEGRITY="변경됨"

if [ "$CLI_RC" -eq 124 ]; then
  finish 1 "미실행" "$TOOL 시간 초과 (${TIMEOUT_SECONDS}초). CROSS_VERIFY_TIMEOUT 으로 늘릴 수 있습니다." "$INTEGRITY"
fi
if [ "$CLI_RC" -ne 0 ]; then
  finish 1 "미실행" "$TOOL 실행 실패 (exit $CLI_RC). 인증·모델 접근·사용량 제한을 확인하세요." "$INTEGRITY"
fi
if [ "$INTEGRITY" != "유지" ]; then
  finish 1 "무효" "검증 중 원본 작업 트리가 바뀌었습니다. 'git status' 로 확인하세요." "$INTEGRITY"
fi

VERDICT="$(grep -E '^[[:space:]]*VERDICT:[[:space:]]*(PASS|FAIL)[[:space:]]*$' "$OUTPUT" 2>/dev/null \
  | tail -n 1 | sed -E 's/.*VERDICT:[[:space:]]*//; s/[[:space:]]*$//')"
case "$VERDICT" in
  PASS) finish 0 "PASS" "검증 통과" "$INTEGRITY" ;;
  FAIL) finish 1 "FAIL" "검증 도구가 문제를 보고했습니다." "$INTEGRITY" ;;
  *) finish 1 "판정 없음" "출력에 'VERDICT: PASS|FAIL' 줄이 없습니다." "$INTEGRITY" ;;
esac
