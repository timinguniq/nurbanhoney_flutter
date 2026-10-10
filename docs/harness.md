# 개발 하네스

코드 변경을 같은 절차로 검사하기 위한 스크립트·Git 훅·에이전트 설정이다. 작업 지침은 `AGENTS.md`,
구조와 금지 의존성은 `docs/architecture.md`, 테스트 규칙은 `test/README.md` 에 있다.

## 구성 요소

| 파일 | 책임 |
|---|---|
| `tool/commit_gate.sh` | 공통 게이트. 아래 검사를 순서대로 실행하고 하나라도 실패하면 non-zero 로 끝난다. |
| `tool/setup.sh` | 새 clone·worktree 준비: 훅 등록, secret 복사(`--secrets-from`), `pub get`, secret 확인, 전체 검사(`--check`). |
| `.githooks/pre-commit` | 커밋 대상 작업 트리의 루트를 구해 그 트리의 `tool/commit_gate.sh --pre-commit` 을 실행한다. |
| `tool/dep_guard.py` | 레이어 금지 의존성 검사(`docs/architecture.md`). |
| `tool/agent_commit_guard.py` | Claude Code·Codex 공용 PreToolUse(Bash) 어댑터. 훅 우회 커밋과 훅 미등록 트리 커밋을 차단한다. |
| `.claude/settings.json`, `.codex/hooks.json` | 위 어댑터를 Bash 실행 전 훅으로 등록한다. |
| `docs/agents/*.md` | 검증 역할 정의(기준). `.claude/agents/*.md`, `.codex/agents/*.toml` 은 이를 가리키는 래퍼다. |
| `tool/verify_copy.sh` | 커밋되지 않은 변경과 secret(또는 `--stub-secrets` 로 더미 값)을 포함한 검증용 임시 복제본을 만든다. |
| `tool/cross_verify.sh` | 반대편 에이전트 도구로 교차 검증을 실행하고 원본 무결성을 확인한다. |
| `tool/ci/stub_secrets.sh`, `.github/workflows/ci.yml` | CI 에서 더미 secret 을 만들고 게이트를 실행한다. |
| `.worktreeinclude` | Claude Code worktree 와 `verify_copy.sh` 가 복사할 gitignore 대상 secret 목록. |
| `tool/test/*_test.py` | 하네스 자체 테스트(임시 Git 저장소, 가짜 flutter·codex·claude). 실행기: `tool/test/run_tests.py`. |

## 활성 검사

`tool/commit_gate.sh` 의 실행 순서다. 모든 판정은 각 도구의 **종료 코드**로 한다(출력 문구를 검색해 성공을 판정하지 않는다).

| # | 검사 | 실패 조건 |
|---|---|---|
| 1 | 필수 도구·파일 | `git`·`python3`·`flutter` 가 PATH 에 없음, `pubspec.yaml`·`tool/dep_guard.py`·`tool/test/run_tests.py` 없음, secret 파일 없음 |
| 2 | staged ↔ 작업 트리 일치 (`--pre-commit` 만) | 검사 경로에 stage 하지 않은 변경이나 untracked 파일이 있음 |
| 3 | 레이어 의존성 `python3 tool/dep_guard.py` | 금지 import (exit 1), 설정 오류 (exit 2) |
| 4 | 의존성 설치 `flutter pub get --enforce-lockfile` (먼저 `--offline`, 실패하면 네트워크) | 실패, 또는 (`--pre-commit`) 설치가 추적 파일을 바꿈 |
| 5 | 정적 분석 `flutter analyze --no-pub --no-fatal-warnings --no-fatal-infos` | 종료 코드 non-zero: error 가 있거나 분석기가 실행되지 못함 |
| 6 | 테스트 `flutter test --no-pub` (`TEST_TARGETS`, 지금은 루트) | 실패, 또는 테스트 0개(종료 코드 79) |
| 7 | 하네스 테스트 `python3 tool/test/run_tests.py` | 실패, 또는 발견된 테스트 0개. `--pre-commit` 에서는 하네스 파일이 staged 됐을 때만 실행 |

- **warning·info 정책:** 차단하지 않는다. 기존 코드에 warning·info 가 많이 남아 있어서다(`flutter analyze` 로 현재 개수 확인). 새 경고를 막는 방식(기준 개수 비교 등)은 추후 과제다.
- **검사 경로**(2·4번): 게이트가 작업 트리에서 읽는 파일 전부다. 앱 검사용 `**/*.dart`, `**/pubspec.yaml`, `**/pubspec.lock`,
  `**/analysis_options.yaml`과 하네스 테스트용 `tool/**`, `.githooks/**`, `.claude/settings.json`, `.claude/agents/**`,
  `.codex/**`, `docs/agents/**`, `.worktreeinclude`, `.github/workflows/**`, `.gitignore`.
  그 밖의 파일(예: 문서, 루트의 메모 파일)은 untracked 여도 커밋을 막지 않는다.
- **secret 파일**(1번): `lib/config/config.dart`, `lib/config/src/secret.dart`, `lib/firebase_options.dart`,
  `domain/dio_domain/lib/src/models/dio_main_api.dart`. 없으면 analyze 가 컴파일 오류를 내므로 먼저 이유를 보여준다.
- **훅 환경 변수:** git 이 훅에 넘기는 `GIT_DIR`·`GIT_INDEX_FILE` 등은 게이트의 git 명령에만 쓰고, flutter·python 은 이 변수 없이
  실행한다. 그대로 넘기면 flutter 가 SDK 버전을 이 저장소에서 읽어 worktree 커밋이 실패한다.
- **측정한 소요 시간**(M 시리즈 Mac, 캐시 있음): 전체 모드 약 21초, Dart 파일만 바꾼 pre-commit 약 4초.

## 검사 대상 기준

| 상황 | 검사 대상 | 하네스 테스트 실행 여부 |
|---|---|---|
| 일반 커밋 (`--pre-commit`) | 작업 트리 전체. 2번 검사로 커밋 대상(staged)과 같음을 보장 | `git diff --cached` 에 하네스 경로가 있을 때 |
| 첫 커밋 (HEAD 없음) | 위와 같다. `git diff --cached`·`git diff` 는 HEAD 없이 동작한다 | 위와 같다 |
| `git commit -a` / `git commit <경로>` | git 이 만든 임시 index 기준. 커밋에 들어가지 않는 변경이 검사 경로에 있으면 2번에서 차단 | 위와 같다 |
| 수동 실행·CI (전체 모드) | 작업 트리 전체. 변경 파일만 고르지 않으므로 비교 기준 커밋이 필요 없다 | 항상 |

staged 와 작업 트리가 다르면 자동으로 stash 하지 않고 차단한다. 자동 stash 는 복원 실패 시 작업을 잃을 수 있어서다.
`git add` 하거나 `git stash push --keep-index --include-untracked` 로 치운 뒤 다시 커밋한다.

## 제외한 검사

| 검사 | 제외 이유 | 다시 볼 시점 |
|---|---|---|
| 커버리지 임계값 | 실제 테스트가 거의 없어 분모가 의미 없다 | 패키지 테스트가 생기고 `flutter test --coverage` 기준을 정할 때 |
| 복잡도·CRAP | 커버리지 없이 계산할 수 없다. Dart AST 도구와 analyzer 버전 호환성 검증도 필요하다 | 커버리지 도입 후 |
| 편집 사전 훅(짝 테스트 확인) | 테스트 없는 기존 코드가 대부분이라 거의 모든 편집을 막는다 | `lib/` 의 테스트 비율이 올라갔을 때 |
| 코드 생성 최신 여부 | build_runner 를 4곳에서 돌려야 해 느리다(커밋 때마다 수십 초) | 생성 파일 불일치 사고가 생기면 CI 에만 추가 |
| `dep_audit`(의존성 현황 측정) | 지금 필요한 의사결정이 없다 | 패키지 구조를 정리할 때 |
| `prepare-commit-msg`·`commit-msg` | 커밋 메시지 규칙(`[Tag] 한국어`)은 AGENTS.md 로 충분하다. 과거 기록에 `feat:` 형식도 섞여 있다 | 규칙 위반이 반복되면 |
| 레이어 건너뛰기 금지(`lib` → `data`) | 문서 규칙은 "역방향 금지" 뿐이고 기존 사용처가 있다(`docs/architecture.md`) | 금지로 정하면 dep_guard 에 규칙과 사례 테스트 추가 |
| 패키지 테스트 실행 | 패키지의 `test/*_test.dart` 가 모두 빈 `main()` 이다 | 실제 테스트를 넣을 때 `TEST_TARGETS` 에 추가(`test/README.md`) |

## 훅 등록

### 이 저장소(이미 등록됨)

```bash
chmod +x tool/*.sh tool/*.py tool/ci/*.sh tool/test/run_tests.py .githooks/pre-commit
git config --local core.hooksPath .githooks
```

등록 전에는 `core.hooksPath` 가 비어 있었고 `.git/hooks/` 에는 `*.sample` 만 있어서 병합할 기존 훅이 없었다.
다른 훅 도구를 쓰게 되면 `.githooks/pre-commit` 에서 그 훅을 부르도록 합친다(`core.hooksPath` 는 하나만 지정할 수 있다).

### 새 clone

Git 로컬 설정과 gitignore 대상 파일은 clone 으로 전달되지 않는다. 다음 한 줄로 준비한다.

```bash
bash tool/setup.sh --secrets-from <secret 이 있는 기존 체크아웃> --check
```

훅을 등록하고(`core.hooksPath` 가 다른 값이면 덮어쓰지 않고 멈춘다), `.worktreeinclude` 의 gitignore 대상 파일을
기존 체크아웃에서 복사하고(이미 있는 파일은 보존), `flutter pub get --enforce-lockfile` 후 필수 secret 을 확인하고,
`--check` 면 게이트 전체를 돌린다. 기존 체크아웃이 없으면 secret 을 따로 받아 둔 뒤 `--secrets-from` 없이 실행한다.

훅을 등록하지 않으면 에이전트 가드가 에이전트의 커밋을 막고 등록 명령을 안내한다. 사람이 터미널에서 커밋하면 막히지 않으니 3번을 빠뜨리지 않는다.

### worktree

- `core.hooksPath=.githooks` 는 상대 경로라서 worktree 에서는 **그 worktree 의** `.githooks/pre-commit` 과 게이트가 실행된다.
  그 트리에 게이트가 없으면 커밋을 막는다.
- Claude Code 가 만드는 worktree(`--worktree`, 서브에이전트 `isolation: worktree`)는 `.worktreeinclude` 의 secret 을 복사한다.
- 그 밖의 worktree(직접 `git worktree add`, Codex `--worktree`)는 secret 이 없어서 게이트가 막는다.
  그 worktree 에서 `bash tool/setup.sh --secrets-from <메인 트리 경로>` 를 실행한다.

### 에이전트 훅

| 도구 | 설정 | 활성화 |
|---|---|---|
| Claude Code | `.claude/settings.json` → `PreToolUse` `Bash` | 저장소를 열면 적용된다 |
| Codex | `.codex/hooks.json` → `PreToolUse` `Bash` | **수동 1회:** 프로젝트를 trust 하고 Codex 에서 `/hooks` 로 훅을 검토·승인한다. 훅 파일 내용이 바뀌면 다시 승인해야 한다 |

어댑터 동작:

- `git commit` 을 찾아(`git -C`, `git -c`, 설정된 별칭과 `-c alias.X=…`·환경 변수로 정의한 별칭, `cd … &&`,
  `bash -c '…'`, 환경 변수 접두사·`export` 포함) 다음을 차단한다(exit 2). 셸 별칭(`!…`)과 `bash -c` 안의 명령에는
  git·셸처럼 바깥의 `-c` 설정과 환경 변수를 물려준 상태로 분석한다.
- 별칭(연쇄 포함, 순환은 중단)과 실제로 적용될 `core.hooksPath` 는 가드가 규칙을 흉내 내지 않고, 커밋 명령과 같은 전역 옵션
  (`-c`, `--config-env`, `-C`, `--git-dir` 등)·환경 변수로 `git config --get` 을 실행해 git 에 직접 묻는다.
  git 이 그 옵션으로 실행을 거부하면(예: `--config-env` 의 변수가 없음) 커밋도 실패하므로 막지 않는다.
  - 훅 우회 옵션: `--no-verify` 와 그 축약(`--no-veri` 등, git 이 받아들인다), `-n`(묶음 `-anm` 포함)
  - 커밋에 붙은 훅 경로 덮어쓰기: `-c core.hooksPath=…`, `--config-env=core.hooksPath=…`,
    환경 변수 `GIT_CONFIG_PARAMETERS`·`GIT_CONFIG_KEY_<n>=core.hooksPath`
  - 커밋 대상 트리의 `core.hooksPath` 가 `.githooks` 가 아님, `.githooks/pre-commit` 이 실행 불가, `tool/commit_gate.sh` 없음

  커밋이 아닌 명령(`git log` 등)은 검사하지 않는다.
- here-document 본문(`<<'EOF'` … `EOF`)은 데이터로 보고 명령으로 해석하지 않는다. 본문에 `git commit` 이 적혀 있어도 막지 않는다.
- 명령은 따옴표·이스케이프·`$( )`·백틱을 아는 토크나이저로 나눈다. 따옴표 안의 `;`·`&&`·`|` 는 구분자가 아니고,
  `$( )`·백틱 안의 명령도 그 위치의 경로·환경으로 검사하며, `( )` 서브셸 안의 `cd`·`export` 는 바깥 명령에 영향을
  주지 않는다. `if`/`then`/`do`/`{`/`!` 같은 셸 키워드 뒤의 명령도 검사한다. 래퍼(`command`, `exec`, `time`, `nohup`,
  `nice`, `env`)는 옵션과 옵션 값(붙여 쓴 `-C/path`·`-uNAME` 포함)을 건너뛴다. `env -C <dir>` 는 그 명령의 디렉터리로,
  `env -u`·`env -i`·셸 `unset` 은 git 이 보는 환경에서 변수를 지운 것으로, `env -S '<명령>'` 은 명령으로 펼쳐 검사한다.
- 게이트는 실행하지 않는다. 등록된 Git 훅이 커밋 때 실행하므로 같은 검사가 두 번 돌지 않는다.
  **측정:** Claude Code 로 커밋 1회를 실행했을 때 flutter 호출은 `pub get`·`analyze`·`test` 각 1회였다.
- 어댑터 내부 오류·입력 해석 실패도 차단한다. 어댑터가 실행조차 못 하면(예: `python3` 없음) 두 도구 모두 비차단 오류로
  처리하므로, 실제 차단은 Git 훅이 맡는다.
- 한계: 명령 해석은 최선 노력이다. 다음은 따라가지 않는다: 파일로 저장한 스크립트 실행(`sh x.sh`), `eval`, 변수 확장
  (`git $CMD`), 셸 함수, 이전 Bash 호출에서 export 한 환경, `sudo`·`xargs`·`find -exec` 같은 기타 실행기.
  교차 리뷰(2026-10-10)에서 확인했지만 고치지 않은 사례도 있다:
  명령 앞 리다이렉션(`2>/dev/null git commit -n`), 인용하지 않은 heredoc 본문 속 `$(git commit -n)`,
  같은 명령의 접두 대입 뒤 `env -u` 로 그 변수를 지우는 순서(`A=1 env -u A git commit`). Codex 는 일부 도구 경로가 훅을 거치지 않을 수 있다고 문서화하고 있다.
  사람이 터미널에서 `--no-verify` 로 커밋하는 것은 막지 않는다. 그래서 이 가드는 보조 수단이고, 우회 시도는 리뷰에서도 확인한다.

## 교차 검증

```bash
bash tool/cross_verify.sh <codex|claude> <verifier|code-reviewer|mutation-verifier> ["추가 지시"]
```

1. 원본 작업 트리의 지문(HEAD, `git status`, `git diff HEAD`, `git diff --cached`, untracked 파일 해시,
   `.worktreeinclude` secret 내용 해시)을 기록한다.
2. `tool/verify_copy.sh --stub-secrets` 로 임시 복제본을 만든다: HEAD + 커밋되지 않은 변경(모두 staged) + 더미 secret
   (`tool/ci/stub_secrets.sh`), origin 원격 제거. 검증 도구에는 실제 키를 넘기지 않는다.
3. 역할 문서와 실행 맥락을 프롬프트로 넘겨 복제본에서 실행한다.
   Codex: `codex exec -C <복제본> -s workspace-write`. flutter 는 실행할 때마다 SDK 의 `bin/cache` 에 쓰고 pub·analyze 는
   사용자 캐시(`~/.pub-cache`, `~/.dartServer`, `~/.dart-tool` 등)에 쓰므로, 있는 경로만 `--add-dir` 로 쓰기를 허용한다.
   이것이 없으면 Codex 샌드박스 안에서 flutter 명령이 모두 실패한다. 또 `flutter test` 는 127.0.0.1 에 서버 소켓을
   열어야 하므로 샌드박스 네트워크를 허용한다(`-c sandbox_workspace_write.network_access=true`). 복제본의 secret 이
   더미 값이라 실제 키가 밖으로 나갈 수 없다.
   Claude: `claude -p --permission-mode acceptEdits` + 허용 도구 목록.
   두 CLI 모두 표준 입력을 `/dev/null` 로 막는다(표준 입력이 열려 있으면 EOF 까지 기다리며 멈춘다).
   `CROSS_VERIFY_TIMEOUT`(초, 기본 1800)을 넘기면 중단하고 **미실행**으로 기록한다.
4. 지문을 다시 비교한다. 다르면 결과를 **무효**로 처리한다.
5. 출력의 마지막 `VERDICT: PASS|FAIL` 줄로 판정한다. 결과는 `.harness/reports/<시각>-<도구>-<역할>.md` 에 남는다(gitignore 대상).

| 결과 | 종료 코드 | 보고서 판정 |
|---|---|---|
| PASS, 원본 유지 | 0 | PASS |
| FAIL | 1 | FAIL |
| `VERDICT` 줄 없음 | 1 | 판정 없음 |
| CLI 없음, 실행 실패(인증·모델 접근·사용량 제한), 시간 초과 | 1 | 미실행 |
| 원본 작업 트리가 바뀜 | 1 | 무효 |

뮤테이션 검증은 회귀·아키텍처·코드 리뷰 다음에 단독으로 실행한다. 복제본에서만 파일을 바꾸므로 원본은 안전하다.
같은 도구의 서브에이전트(`.claude/agents/`, `.codex/agents/`)로 빠르게 확인할 수 있지만 교차 검증을 대신하지 않는다.

## CI

`.github/workflows/ci.yml` 은 `main` push 와 pull request 에서 다음을 실행한다.

1. Flutter `3.47.5` 설치(로컬 SDK 와 같은 버전. 로컬 Flutter 를 올리면 함께 올린다)
2. `bash tool/ci/stub_secrets.sh` — gitignore 대상 secret 을 더미 값으로 만든다(`CI=true` 일 때만 동작, 있는 파일은 건드리지 않음)
3. `bash tool/commit_gate.sh` — 전체 모드. 테스트·analyze 실패는 종료 코드로 job 을 실패시킨다

변경 파일만 검사하지 않으므로 기준 커밋이나 전체 Git 이력이 필요 없다. 앱 코드가 secret 식별자를 새로 쓰면
`tool/ci/stub_secrets.sh` 도 고쳐야 한다(CI analyze 가 실패해 알려준다).

## 실패 해결

| 게이트 메시지 | 해결 |
|---|---|
| `필수 도구 'flutter'…` | Flutter SDK 를 설치하고 PATH 에 추가한다. GUI 앱에서 커밋하면 셸 PATH 가 적용되지 않을 수 있다 |
| `gitignore 대상 secret 파일이 없습니다` | 출력된 `cp` 명령으로 메인 트리에서 복사하거나 파일을 받아 둔다 |
| `커밋 대상(staged)과 작업 트리가 다릅니다` | 나열된 파일을 `git add` 하거나 `git stash push --keep-index --include-untracked` |
| `레이어 의존성 검사 실패` | 출력된 `파일:줄` 의 import 를 고친다. 규칙은 `docs/architecture.md` |
| `의존성 설치 실패` | `pubspec.yaml` 을 바꿨다면 `flutter pub get` 으로 `pubspec.lock` 을 갱신해 함께 stage 한다 |
| `의존성 설치가 추적 파일을 변경했습니다` | 바뀐 파일(보통 `pubspec.lock`·`analysis_options.yaml`)을 확인해 stage 한다 |
| `flutter analyze 실패` | 출력된 `error •` 줄을 고친다. error 줄이 없으면 분석기 실행 실패이니 전체 로그 경로를 연다 |
| `flutter test 실패` / `테스트가 0개` | 실패한 테스트를 고친다. 0개면 `test/` 에 실제 테스트가 있는지 확인한다 |
| `하네스 테스트 실패` | `python3 tool/test/run_tests.py -v` 로 실패한 사례를 확인한다 |
| `[commit-guard] ✗ … 훅을 우회` | 우회하지 말고 게이트 실패 원인을 고친다 |
| `[commit-guard] ✗ … Git 훅이 등록되지 않았습니다` | `git config --local core.hooksPath .githooks` |
| 테스트가 `dot-shorthands` 같은 Flutter SDK 컴파일 오류 | `.dart_tool` 이 이전 SDK 로 만들어졌다. `flutter pub get` |

게이트가 실패하면 로그 디렉터리를 지우지 않고 경로를 출력한다(`$TMPDIR/commit_gate.*`).

## 유지보수

- **하네스를 고칠 때:** `python3 tool/test/run_tests.py -v` 로 확인한다. 하네스 파일을 stage 한 커밋에서는 게이트가 자동으로 실행한다.
- **Flutter 를 올릴 때:** `flutter pub get` 후 `pubspec.lock`·`analysis_options.yaml` 변경을 확인해 커밋하고, `ci.yml` 의 `flutter-version` 을 맞춘다.
- **secret 이 늘어날 때:** `tool/commit_gate.sh` 의 `REQUIRED_SECRET_FILES`, `.worktreeinclude`, `tool/ci/stub_secrets.sh` 를 함께 고친다.
  `tool/test/harness_config_test.py` 가 셋이 어긋나면 실패한다.
- **역할을 추가할 때:** `docs/agents/<역할>.md` 와 두 래퍼를 함께 만든다. 하네스 테스트가 역할 집합 차이를 잡는다.
