#!/usr/bin/env bash
# 검증용 임시 복제본을 만든다.
#   bash tool/verify_copy.sh [--stub-secrets] <새 디렉터리>
#
# 복제본 = 현재 HEAD + 커밋되지 않은 변경(staged·unstaged·untracked, 모두 staged 로 적용)
#        + .worktreeinclude 에 적힌 gitignore 대상 secret 파일.
#          --stub-secrets 면 실제 secret 대신 tool/ci/stub_secrets.sh 의 더미 파일을 만든다.
# 검토할 변경은 복제본에서 `git diff --cached` 로 본다. 복제본에는 origin 이 없어 push 할 수 없다.
# 원본 작업 트리는 읽기만 한다. 파일을 바꾸는 검증(뮤테이션 등)은 복제본에서만 한다.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
fail() { echo "[verify-copy] ✗ $*" >&2; exit 1; }

STUB_SECRETS=0
if [ "${1:-}" = "--stub-secrets" ]; then
  STUB_SECRETS=1
  shift
fi
DEST="${1:-}"
[ -n "$DEST" ] || fail "usage: bash tool/verify_copy.sh [--stub-secrets] <새 디렉터리>"
[ ! -e "$DEST" ] || fail "이미 존재하는 경로입니다: $DEST"
head="$(git -C "$ROOT" rev-parse -q --verify HEAD)" || fail "HEAD 가 없습니다(첫 커밋 전에는 복제본을 만들 수 없습니다)."

created=0
cleanup() { [ "$created" = 1 ] || rm -rf "$DEST"; }
trap cleanup EXIT

git clone --quiet --no-checkout "$ROOT" "$DEST"
git -C "$DEST" remote remove origin
git -C "$DEST" checkout --quiet --detach "$head"

patch="$(mktemp "${TMPDIR:-/tmp}/verify_copy.XXXXXX")"
git -C "$ROOT" diff HEAD --binary >"$patch"
if [ -s "$patch" ]; then
  git -C "$DEST" apply --index --whitespace=nowarn "$patch" || { rm -f "$patch"; fail "커밋되지 않은 변경을 적용하지 못했습니다."; }
fi
rm -f "$patch"

git -C "$ROOT" ls-files --others --exclude-standard -z | while IFS= read -r -d '' file; do
  mkdir -p "$DEST/$(dirname "$file")"
  cp -Pp "$ROOT/$file" "$DEST/$file"  # -P: 심볼릭 링크는 링크로 복사
done
git -C "$DEST" add -A

if [ "$STUB_SECRETS" = 1 ]; then
  [ -f "$DEST/tool/ci/stub_secrets.sh" ] || fail "복제본에 tool/ci/stub_secrets.sh 가 없습니다."
  (cd "$DEST" && CI=true bash tool/ci/stub_secrets.sh >/dev/null) || fail "더미 secret 을 만들지 못했습니다."
elif [ -f "$ROOT/.worktreeinclude" ]; then
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    case "$pattern" in ""|\#*) continue ;; esac
    pattern="${pattern#/}"
    for source in "$ROOT"/$pattern; do
      [ -e "$source" ] || continue
      relative="${source#"$ROOT"/}"
      git -C "$ROOT" check-ignore -q -- "$relative" || continue
      mkdir -p "$DEST/$(dirname "$relative")"
      cp -RLp "$source" "$DEST/$relative"  # -L: secret 이 링크여도 복제본에는 독립된 파일로 둔다
    done
  done <"$ROOT/.worktreeinclude"
fi

created=1
echo "$DEST"
