#!/usr/bin/env bash
# 새 clone·worktree 를 개발 가능한 상태로 준비한다(docs/harness.md "새 clone").
#   bash tool/setup.sh [--secrets-from <기존 체크아웃 경로>] [--check]
#
#   1. Git 훅 등록: core.hooksPath=.githooks (다른 값이 이미 있으면 덮어쓰지 않고 멈춘다)
#   2. --secrets-from: .worktreeinclude 에 적힌 gitignore 대상 파일을 그 경로에서 복사한다.
#      이미 있는 파일은 덮어쓰지 않고, 이 저장소에서 gitignore 대상이 아닌 파일은 복사하지 않는다.
#   3. flutter pub get --enforce-lockfile
#   4. 게이트에 필요한 secret 이 모두 있는지 확인한다(tool/commit_gate.sh 의 REQUIRED_SECRET_FILES).
#   5. --check: bash tool/commit_gate.sh 로 전체 검사를 실행한다.
# macOS 기본 bash 3.2 에서도 동작해야 한다.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT" || exit 1

SECRETS_FROM=""
CHECK=0
while [ $# -gt 0 ]; do
  case "$1" in
    --secrets-from) SECRETS_FROM="${2:-}"; shift 2 ;;
    --check) CHECK=1; shift ;;
    *) echo "usage: bash tool/setup.sh [--secrets-from <기존 체크아웃 경로>] [--check]" >&2; exit 2 ;;
  esac
done

step() { echo "[setup] ▶ $*"; }
pass() { echo "[setup] ✓ $*"; }
fail() { echo "[setup] ✗ $*" >&2; exit 1; }

for tool in git flutter python3; do
  command -v "$tool" >/dev/null 2>&1 || fail "필수 도구 '$tool' 를 PATH 에서 찾을 수 없습니다."
done

step "Git 훅 등록"
current="$(git config --local --get core.hooksPath)"
if [ -z "$current" ]; then
  git config --local core.hooksPath .githooks || fail "core.hooksPath 를 설정하지 못했습니다."
  pass "core.hooksPath=.githooks 로 등록"
elif [ "$current" = ".githooks" ]; then
  pass "이미 등록됨 (core.hooksPath=.githooks)"
else
  fail "core.hooksPath 가 이미 '$current' 입니다. 그 훅과 .githooks/pre-commit 을 어떻게 합칠지 정한 뒤 직접 바꾸세요(docs/harness.md '훅 등록')."
fi

if [ -n "$SECRETS_FROM" ]; then
  step "secret 복사 ($SECRETS_FROM)"
  [ -d "$SECRETS_FROM" ] || fail "경로가 없습니다: $SECRETS_FROM"
  SOURCE="$(cd "$SECRETS_FROM" && pwd -P)"
  [ "$SOURCE" != "$ROOT" ] || fail "--secrets-from 이 이 저장소 자신입니다."
  copied=0
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    case "$pattern" in ""|\#*) continue ;; esac
    for source in "$SOURCE"/${pattern#/}; do
      [ -e "$source" ] || continue
      # 디렉터리면 안의 파일 하나하나를 본다. 링크는 따라가 독립된 파일로 복사한다.
      while IFS= read -r file; do
        relative="${file#"$SOURCE"/}"
        if [ -e "$relative" ] || [ -L "$relative" ]; then
          echo "  - 이미 있음: $relative"
          continue
        fi
        if ! git check-ignore -q --no-index -- "$relative"; then
          echo "  - 건너뜀(gitignore 대상 아님): $relative"
          continue
        fi
        mkdir -p "$(dirname "$relative")" && cp -Lp "$file" "$relative" || fail "복사 실패: $relative"
        echo "  + 복사: $relative"
        copied=$((copied + 1))
      done < <(find -L "$source" -type f | LC_ALL=C sort)
    done
  done <.worktreeinclude
  pass "secret ${copied}개 복사"
fi

step "의존성 설치 (flutter pub get --enforce-lockfile)"
flutter pub get --enforce-lockfile >/dev/null 2>"${TMPDIR:-/tmp}/setup_pub_get.$$" || {
  tail -n 20 "${TMPDIR:-/tmp}/setup_pub_get.$$" >&2
  rm -f "${TMPDIR:-/tmp}/setup_pub_get.$$"
  fail "flutter pub get 실패"
}
rm -f "${TMPDIR:-/tmp}/setup_pub_get.$$"
pass "의존성 설치"

step "secret 확인"
missing=""
for file in $(sed -n '/^REQUIRED_SECRET_FILES=(/,/^)/p' tool/commit_gate.sh | grep -oE '"[^"]+"' | tr -d '"'); do
  [ -f "$file" ] || missing="$missing $file"
done
if [ -n "$missing" ]; then
  printf '  없음: %s\n' $missing >&2
  fail "게이트에 필요한 secret 이 없습니다. 기존 체크아웃이 있다면 --secrets-from <경로> 로 다시 실행하고, 없다면 따로 받아 두세요(AGENTS.md 'gitignore 된 secret')."
fi
pass "필수 secret 모두 있음"

if [ "$CHECK" = 1 ]; then
  step "전체 검사 (tool/commit_gate.sh)"
  bash tool/commit_gate.sh || fail "게이트 실패 (위 출력 참고)"
fi

echo "[setup] ✓ 준비 완료. Codex 를 쓴다면 Codex 에서 이 프로젝트를 trust 하고 /hooks 로 .codex/hooks.json 을 승인하세요."
