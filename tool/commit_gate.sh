#!/usr/bin/env bash
# 커밋 게이트: 채택한 검사를 순서대로 실행하고, 하나라도 실패하면 non-zero 로 끝난다.
# 검사 목록·정책·실패 해결법은 docs/harness.md 참고.
#
#   bash tool/commit_gate.sh               # 작업 트리 전체 검사 (수동 실행·CI)
#   bash tool/commit_gate.sh --pre-commit  # .githooks/pre-commit 에서 호출
#
# --pre-commit 은 staged 내용과 작업 트리가 같은지 먼저 확인한다. 게이트는 작업 트리를
# 검사하므로, 둘이 다르면 커밋 대상이 아닌 내용을 검사하게 되어 차단한다.
# macOS 기본 bash 3.2 에서도 동작해야 한다(연관 배열·mapfile 사용 금지).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT" || exit 1

MODE=full
case "${1:-}" in
  "") ;;
  --pre-commit) MODE=pre-commit ;;
  *) echo "usage: bash tool/commit_gate.sh [--pre-commit]" >&2; exit 2 ;;
esac

# 테스트를 실행할 Flutter 패키지 디렉터리(ROOT 기준). 실제 테스트가 있는 패키지만 둔다.
# 루트가 아닌 패키지는 정적 분석 전에 그 디렉터리에서 pub get 을 실행한다. 루트 analyze 가 패키지의 test/ 도
# 분석하므로, 패키지 dev 의존성(package:test 등)이 없으면 새 clone 에서 분석이 실패한다.
# 패키지는 pubspec.lock 을 커밋하지 않으므로 lockfile 을 강제하지 않는다.
TEST_TARGETS=("." "data/dio_repository" "application/dio_service")

# analyze 에 필요한 gitignore 대상 파일. 없으면 컴파일 오류가 나므로 먼저 이유를 표시한다.
# .worktreeinclude 와 tool/ci/stub_secrets.sh 도 같은 파일을 다룬다(하네스 테스트가 확인).
REQUIRED_SECRET_FILES=(
  "lib/config/config.dart"
  "lib/config/src/secret.dart"
  "lib/firebase_options.dart"
  "domain/dio_domain/lib/src/models/dio_main_api.dart"
)

# 앱 검사(analyze·test·dep_guard) 결과에 영향을 주는 경로.
CHECK_PATHSPECS=(
  ':(glob)**/*.dart'
  ':(glob)**/pubspec.yaml'
  ':(glob)**/pubspec.lock'
  ':(glob)**/analysis_options.yaml'
  ':(glob)tool/**'
  ':(glob).githooks/**'
)

# 하네스 테스트가 읽는 파일. --pre-commit 에서는 이 경로가 staged 됐을 때만 하네스 테스트를 실행한다.
HARNESS_PATHSPECS=(
  ':(glob)tool/**'
  ':(glob).githooks/**'
  ':(glob).claude/settings.json'
  ':(glob).claude/agents/**'
  ':(glob).codex/**'
  ':(glob)docs/agents/**'
  ':(glob).worktreeinclude'
  ':(glob).github/workflows/**'
  ':(glob).gitignore'
)

# --pre-commit 에서 staged 와 작업 트리가 같아야 하는 경로: 게이트가 작업 트리에서 읽는 모든 파일.
MATCH_PATHSPECS=("${CHECK_PATHSPECS[@]}" "${HARNESS_PATHSPECS[@]}")

LOG_DIR="$(mktemp -d "${TMPDIR:-/tmp}/commit_gate.XXXXXX")" || exit 1
KEEP_LOGS=0
cleanup() { [ "$KEEP_LOGS" = 1 ] || rm -rf "$LOG_DIR"; }
trap cleanup EXIT

# git 이 훅에 넘기는 저장소 위치 변수. 게이트의 git 명령은 이 값으로 커밋 대상 index 를 본다.
# flutter 처럼 내부에서 git 을 부르는 도구가 물려받으면 엉뚱한 저장소를 읽는다(worktree 에서는 Flutter SDK
# 버전을 이 저장소 커밋으로 읽어 pub get 이 실패한다). 그래서 git 이 아닌 도구는 이 변수 없이 실행한다.
GIT_LOCATION_VARS="GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE"
without_git_location() { (unset $GIT_LOCATION_VARS; exec "$@"); }

step() { echo "[gate] ▶ $*"; }
pass() { echo "[gate] ✓ $*"; }
fail() {
  echo "[gate] ✗ $*" >&2
  exit 1
}

# 명령 출력을 로그 파일에 모으고, 실패하면 로그를 보여준 뒤 종료 코드를 돌려준다.
run_logged() {
  local name="$1"; shift
  local log="$LOG_DIR/$name.log"
  without_git_location "$@" >"$log" 2>&1
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    KEEP_LOGS=1
    echo "----- $name 출력 (exit $rc, 전체 로그: $log) -----" >&2
    # 판정은 종료 코드로만 한다. 아래는 원인을 빨리 찾도록 error 줄을 먼저 보여주는 표시용이다.
    if grep -qE '^[[:space:]]*error •' "$log"; then
      grep -E '^[[:space:]]*error •' "$log" | head -n 40 >&2
      echo "..." >&2
      tail -n 1 "$log" >&2
    else
      tail -n 60 "$log" >&2
    fi
    echo "-----" >&2
  fi
  return "$rc"
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || fail "필수 도구 '$1' 를 PATH 에서 찾을 수 없습니다. $2"
}

# staged 내용과 작업 트리가 같은지 확인한다(검사 경로 한정).
check_tree_matches_index() {
  local unstaged untracked
  unstaged="$(git diff --name-only -- "${MATCH_PATHSPECS[@]}")" \
    || fail "git diff 실행에 실패했습니다."
  untracked="$(git ls-files --others --exclude-standard -- "${MATCH_PATHSPECS[@]}")" \
    || fail "git ls-files 실행에 실패했습니다."
  if [ -n "$unstaged$untracked" ]; then
    {
      [ -z "$unstaged" ] || printf '%s\n' "$unstaged" | sed 's/^/  unstaged 변경: /'
      [ -z "$untracked" ] || printf '%s\n' "$untracked" | sed 's/^/  untracked 파일: /'
    } >&2
    fail "$1 게이트는 작업 트리를 검사하므로 커밋 대상과 같아야 합니다. 위 파일을 git add 하거나 'git stash push --keep-index --include-untracked' 로 치운 뒤 다시 커밋하세요."
  fi
}

echo "[gate] 대상: $ROOT ($MODE)"

step "필수 도구·파일 확인"
require_tool git ""
require_tool python3 "하네스 스크립트 실행에 필요합니다."
require_tool flutter "Flutter SDK 를 설치하고 PATH 에 추가하세요."
for file in pubspec.yaml tool/dep_guard.py tool/test/run_tests.py; do
  [ -f "$file" ] || fail "필수 파일이 없습니다: $file"
done
missing_secrets=""
for file in "${REQUIRED_SECRET_FILES[@]}"; do
  [ -f "$file" ] || missing_secrets="$missing_secrets $file"
done
if [ -n "$missing_secrets" ]; then
  main_tree="$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')"
  if [ -n "$main_tree" ] && [ "$(cd "$main_tree" 2>/dev/null && pwd -P)" != "$ROOT" ]; then
    echo "  메인 작업 트리에서 복사:" >&2
    for file in $missing_secrets; do
      echo "  mkdir -p \"$(dirname "$file")\" && cp \"$main_tree/$file\" \"$file\"" >&2
    done
  fi
  fail "gitignore 대상 secret 파일이 없습니다:$missing_secrets
       기존 체크아웃이 있다면: bash tool/setup.sh --secrets-from <그 경로>
       없다면 따로 받아 두는 파일입니다(AGENTS.md 'gitignore 된 secret').
       CI 라면 'CI=true bash tool/ci/stub_secrets.sh' 로 더미 파일을 만듭니다."
fi
pass "도구·파일 확인"

if [ "$MODE" = pre-commit ]; then
  step "staged 내용과 작업 트리 일치 확인"
  check_tree_matches_index "커밋 대상(staged)과 작업 트리가 다릅니다."
  pass "staged 내용과 작업 트리 일치"
fi

step "레이어 의존성 검사 (tool/dep_guard.py)"
without_git_location python3 tool/dep_guard.py || fail "레이어 의존성 검사 실패 (docs/architecture.md 참고)"

step "의존성 설치 (flutter pub get --enforce-lockfile)"
# 로컬 캐시로 먼저 시도한다. 네트워크가 막힌 샌드박스(Codex 교차 검증)에서도 돌고 더 빠르다.
# 캐시에 없는 패키지가 있으면(새 CI 러너 등) 네트워크로 다시 받는다.
without_git_location flutter pub get --enforce-lockfile --offline >"$LOG_DIR/pub_get_offline.log" 2>&1 \
  || run_logged pub_get flutter pub get --enforce-lockfile \
  || fail "의존성 설치 실패. pubspec.yaml 을 바꿨다면 'flutter pub get' 으로 pubspec.lock 을 갱신해 함께 커밋하세요."
pass "의존성 설치"

for target in "${TEST_TARGETS[@]}"; do
  [ "$target" != "." ] || continue
  step "의존성 설치 ($target: flutter pub get)"
  log_name="pub_get_$(printf '%s' "$target" | tr '/' '_')"
  without_git_location bash -c 'cd "$0" && exec flutter pub get --offline' "$target" >"$LOG_DIR/${log_name}_offline.log" 2>&1 \
    || run_logged "$log_name" bash -c 'cd "$0" && exec flutter pub get' "$target" \
    || fail "$target: 의존성 설치 실패"
  pass "의존성 설치 ($target)"
done
if [ "$MODE" = pre-commit ]; then
  check_tree_matches_index "의존성 설치가 추적 파일을 변경했습니다."
fi

step "정적 분석 (error 만 차단, warning/info 허용)"
run_logged analyze flutter analyze --no-pub --no-fatal-warnings --no-fatal-infos \
  || fail "flutter analyze 실패 (분석 오류 또는 분석기 실행 실패)"
pass "정적 분석"

test_index=0
for target in "${TEST_TARGETS[@]}"; do
  test_index=$((test_index + 1))
  step "테스트 ($target: flutter test)"
  [ -d "$target/test" ] || fail "테스트 디렉터리가 없습니다: $target/test"
  run_logged "test_$test_index" bash -c 'cd "$0" && exec flutter test --no-pub' "$target"
  rc=$?
  if [ "$rc" -eq 79 ]; then
    fail "$target: 실행된 테스트가 0개입니다. 테스트 0개는 통과로 보지 않습니다 (test/README.md 참고)."
  elif [ "$rc" -ne 0 ]; then
    fail "$target: flutter test 실패 (exit $rc)"
  fi
  pass "테스트 ($target)"
done

run_selftest=1
if [ "$MODE" = pre-commit ]; then
  staged_harness="$(git diff --cached --name-only -- "${HARNESS_PATHSPECS[@]}")" \
    || fail "git diff --cached 실행에 실패했습니다."
  [ -n "$staged_harness" ] || run_selftest=0
fi
if [ "$run_selftest" = 1 ]; then
  step "하네스 테스트 (tool/test/run_tests.py)"
  run_logged harness python3 tool/test/run_tests.py || fail "하네스 테스트 실패"
  pass "하네스 테스트"
else
  echo "[gate] - 하네스 테스트 생략 (staged 변경에 하네스 파일 없음)"
fi

echo "[gate] ✓ 모든 검사 통과"
