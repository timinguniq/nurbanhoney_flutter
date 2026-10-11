# AGENTS.md

이 저장소에서 일하는 코딩 에이전트(Claude Code, Codex)의 공통 지침이다. Codex 는 이 파일을 직접 읽고,
Claude Code 는 `CLAUDE.md` 가 이 파일을 불러온 뒤 도구별 사항을 덧붙인다. 공통 내용은 이 파일에만 쓴다.

## 명령

```bash
# 루트와 모든 path 패키지의 의존성 설치·동기화
flutter pub get

# 코드 생성(*.g.dart, *.freezed.dart). @riverpod, @JsonSerializable, @freezed, retrofit
# 애노테이션이 있는 파일을 고친 뒤 반드시 실행한다. build_runner 가 dev_dependencies 에 있는
# 루트와 application/authentication_service, application/navigation_service 에서 각각 실행한다.
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # 계속 감시

# 앱 실행(연결된 기기·시뮬레이터)
flutter run

# 정적 분석(analysis_options.yaml → flutter_lints). 루트에서 실행하면 domain/data/application 도 함께 분석한다.
flutter analyze

# 테스트
flutter test                                          # 루트 앱 테스트
flutter test test/utils/date_format_utils_test.dart   # 파일 하나
(cd application/authentication_service && flutter test)   # 패키지별 테스트

# 런처 아이콘(assets/icon/icon.png 수정 후)
dart run flutter_launcher_icons

# 하네스 (docs/harness.md)
bash tool/commit_gate.sh                 # 커밋 게이트 전체 실행: 의존성 검사·pub get·analyze·test·하네스 테스트
python3 tool/dep_guard.py                # 레이어 의존성 검사만
python3 tool/test/run_tests.py -v        # 하네스 자체 테스트
bash tool/cross_verify.sh <codex|claude> <역할>   # 반대편 도구로 교차 검증
```

## 구조 요약

자세한 내용과 금지 의존성 목록은 `docs/architecture.md` 에 있다.

- 세 레이어가 최상위 디렉터리로 나뉜 Flutter 모노레포다. 각 레이어는 `lib/` 의 하위 폴더가 아니라 독립 Dart/Flutter
  패키지 모음이며, 루트 `pubspec.yaml` 이 `path:` 의존성으로 묶는다.
  - `domain/` 순수 모델·enum·typedef. Flutter·Riverpod 를 import 하지 않는다.
  - `data/` 저장소: Dio HTTP 클라이언트, SharedPreferences 래퍼, 스트림.
  - `application/` 서비스: 저장소를 UI 에 노출하는 Riverpod Provider.
  - `lib/` 화면: nurbanhoney 앱 자체, 기능(feature)별 폴더.
- 의존 방향은 `lib/` → `application/*` → `data/*` → `domain/*` 이며 거꾸로 import 하지 않는다. `tool/dep_guard.py` 가 검사한다.
- 새 데이터 소스는 `domain/<이름>_domain` + `data/<이름>_repository` + `application/<이름>_service` 세트로 나눈다.
  `lib/` 에 바로 넣지 않는다.
- 상태 관리는 Riverpod 로 쓴다. `lib/common/viewmodel/base_viewmodel.dart` 의 `BaseViewModel`(ChangeNotifier)은
  주식·코인 탭 뷰모델에만 남은 레거시이며, 손대는 김에 Riverpod 로 옮긴다.
- **진행 중인 리팩터링:** `lib/app/view/app.dart` 의 `AppView` 는 인증 여부와 관계없이 `HomePageRefactor` 로
  보낸다. 의도된 작업 중 상태이므로 확인 없이 "고치지" 않는다. 주석 처리된 `HomePage` 분기와
  `/// 왜 인지 모르겠지만 SplashPage로 안 감` 메모가 그 영역을 표시한다.

## 작업 원칙

- 기존 코드의 이름·폴더 구조·주석 밀도를 따른다. 새 기능은 `lib/<feature>/view/...` 구조를 따른다.
- 생성 파일(`*.g.dart`, `*.freezed.dart`)은 손으로 고치지 않는다. 애노테이션을 바꾸면 재생성한 결과를 함께 커밋한다.
- 커밋할 내용은 모두 stage 한다. 게이트는 작업 트리를 검사하므로 `.dart`·`pubspec.*`·`analysis_options.yaml`·
  `tool/`·`.githooks/` 에 stage 하지 않은 변경이나 untracked 파일이 있으면 커밋을 막는다.
- Git 훅을 우회하지 않는다(`--no-verify`, `-n`, `-c core.hooksPath=...`). 게이트가 실패하면 원인을 고친다.
  에이전트 훅이 이런 커밋을 차단한다.
- 버그 수정과 새 순수 로직은 테스트를 먼저 쓴다. 실패하는 테스트를 실행해 실패를 확인하고, 수정 후 통과를
  확인한 뒤 두 결과를 작업 보고에 적는다. 짝 테스트 파일이 있다는 것만으로 테스트를 먼저 썼다고 볼 수 없다.
- 테스트 배치·이름·테스트 대역 규칙은 `test/README.md` 를 따른다.

## 완료 기준

1. 관련 테스트를 추가·수정하고 실행했다.
2. `bash tool/commit_gate.sh` 가 통과한다.
3. Dart 소스(생성 파일 제외), `pubspec.yaml`, `analysis_options.yaml` 을 바꿨다면 아래 교차 검증을 실행했다.
4. 작업 보고에 실행한 명령, 결과, 교차 검증 보고서 경로, 실행하지 못한 검증과 그 이유를 적었다.

## 검증 절차

구현한 도구와 **반대편 도구**가 검증한다. Claude Code 가 구현했다면 `codex`, Codex 가 구현했다면 `claude` 다.

```bash
bash tool/cross_verify.sh <반대편> verifier          # 회귀·아키텍처
bash tool/cross_verify.sh <반대편> code-reviewer     # 코드 리뷰
bash tool/cross_verify.sh <반대편> mutation-verifier # 테스트를 추가·수정했을 때만. 위 둘이 끝난 뒤 단독 실행
```

- 역할 정의는 `docs/agents/<역할>.md` 하나가 기준이다. 도구별 래퍼(`.claude/agents/`, `.codex/agents/`)는 그 문서를 가리킨다.
- 검증은 임시 복제본에서 실행되고, 원본 작업 트리가 바뀌면 결과를 무효로 처리한다. 결과는 `.harness/reports/` 에 남는다.
- 종료 코드가 0 이 아니면(FAIL, 판정 없음, CLI 없음, 인증·모델 접근·사용량 제한으로 실행 실패) 통과로 보고하지 않는다.
  실행하지 못했다면 "미실행" 과 이유를 그대로 적는다.
- FAIL 이면 지적을 반영하고 같은 역할을 다시 실행한다.
- 문서만 바꾸거나 하네스만 바꾼 경우에는 하네스 테스트가 검증하므로 교차 검증을 생략할 수 있다. 생략했다면 보고에 적는다.

## 커밋 규칙

한국어 메시지 앞에 영어 태그를 대괄호로 붙인다: `[Update]`, `[Refactor]`, `[Fix]`, `[Add]`, `[Version]`.
`git log` 의 기존 기록을 따른다. 사용자가 요청할 때만 커밋·push 한다.

## gitignore 된 secret

빌드에 필요하지만 저장소에 없다. 따로 받아 두고 커밋하지 않는다.

- `lib/config/*` (`secret.dart` 에 `kakaoNativeAppKey` 등. 디렉터리 내용 전체가 ignore 대상)
- `lib/firebase_options.dart` (`flutterfire configure` 로 생성)
- `domain/dio_domain/lib/src/models/dio_main_api.dart` (`DioMainApi.mainApi` API 기본 URL. `domain/dio_domain/.gitignore` 가 제외)
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

새 clone·worktree 에는 이 파일이 없다. Claude Code 가 만드는 worktree 는 `.worktreeinclude` 로 자동 복사되고, 그 밖의 경우는
`bash tool/setup.sh --secrets-from <기존 체크아웃> --check` 로 훅 등록·secret 복사·의존성 설치·검사를 한 번에 한다
(`docs/harness.md` "새 clone"). CI 는 더미 파일을 만든다(`tool/ci/stub_secrets.sh`).
