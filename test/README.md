# 테스트

## 실행

```bash
flutter test                                          # 루트 앱 테스트 전체
flutter test test/utils/date_format_utils_test.dart   # 파일 하나
flutter test --name '빈 문자열'                         # 이름으로 고르기
(cd application/dio_service && flutter test)          # 패키지 테스트
bash tool/commit_gate.sh                              # 커밋 게이트와 같은 조건으로 실행
```

처음 받았거나 Flutter SDK 를 올린 뒤에는 `flutter pub get` 을 먼저 실행한다. `.dart_tool/` 이 이전 SDK 로
만들어져 있으면 테스트가 Flutter SDK 코드 컴파일 오류(예: `dot-shorthands`)로 실패한다.

## 배치와 이름

- 앱 코드 `lib/<경로>/<이름>.dart` 의 테스트는 `test/<경로>/<이름>_test.dart` 에 둔다.
  예: `lib/utils/date_format_utils.dart` → `test/utils/date_format_utils_test.dart`.
- 패키지 코드(`domain/*`, `data/*`, `application/*`)의 테스트는 그 패키지의 `test/` 에 같은 규칙으로 둔다.
- 파일 이름은 `_test.dart` 로 끝난다. `group` 은 대상 함수·클래스 이름, `test` 설명은 기대 동작을 문장으로 쓴다.

## 테스트 대역

- 테스트는 네트워크·실제 API 서버(`https://nurbanhoney-api.devjj.co.kr`)·Firebase·Kakao SDK 를 호출하지 않는다.
- Riverpod 의존성은 `ProviderContainer(overrides: [...])` 또는 위젯 테스트의 `ProviderScope(overrides: [...])` 로
  가짜 저장소·서비스로 바꾼다.
- `PreferenceStorage` 는 생성자 `plugin:` 으로 `SharedPreferences` 를 받는다. 테스트에서는
  `SharedPreferences.setMockInitialValues({...})` 후 `SharedPreferences.getInstance()` 결과를 넘긴다.
- HTTP 는 `ApiClient`(`data/dio_repository`) 하나를 거친다. 저장소를 쓰는 쪽을 테스트할 때는 Provider override 로
  가짜 저장소를 넣는다. 클라이언트·저장소 자체를 테스트할 때는 `ApiClient(adapter: ...)` 에 가짜 `HttpClientAdapter` 를
  넘긴다(`data/dio_repository/test/api_client_test.dart` 의 `FakeHttpClientAdapter`). 저장소가 던지는 실패는
  `ApiFailure`(`domain/dio_domain`) 뿐이므로 가짜 저장소도 성공 문자열 대신 그 타입을 던진다. 실제 요청이 나가는
  테스트는 만들지 않는다.
- provider 사슬(인증 상태 → `apiClientProvider` → 저장소 → `FutureProvider`)을 통째로 확인할 때는
  `apiHttpClientAdapterProvider` 를 가짜 어댑터로 바꾼다(`application/dio_service/test/`).

## 품질 기준

- 입력과 출력, 즉 동작을 검증한다. private 구현이나 호출 순서에 묶지 않는다.
- 정상 경로와 함께 실패 경로(잘못된 입력, 예외, 빈 응답)를 하나 이상 다룬다.
- 버그 수정은 먼저 실패하는 테스트로 재현하고(실패 실행 결과 기록), 수정 후 통과를 확인한다.
- 테스트를 추가·수정했다면 `mutation-verifier` 교차 검증으로 결함을 실제로 잡는지 확인한다(AGENTS.md "검증 절차").

## 커밋 게이트의 테스트 대상

`tool/commit_gate.sh` 의 `TEST_TARGETS` 에 있는 디렉터리에서 `flutter test --no-pub` 을 실행한다. 지금은 루트(`.`),
`data/dio_repository`, `application/dio_service` 다.

- 실행된 테스트가 0개(`flutter test` 종료 코드 79)이면 실패로 처리한다.
- 루트가 아닌 패키지는 정적 분석 전에 그 디렉터리에서 `flutter pub get --offline`(실패하면 네트워크)을 실행한다. 루트
  `flutter analyze` 가 패키지의 `test/` 도 분석하므로, 그 전에 패키지 dev 의존성이 설치돼 있어야 새 clone 에서 분석이
  통과한다. 패키지는 `pubspec.lock` 을 커밋하지 않으므로(라이브러리 관례) lockfile 을 강제하지 않는다.
- 다른 패키지의 `test/*_test.dart` 는 아직 빈 `main()` 이라 대상에서 뺐다. 실제 테스트를 넣으면 `TEST_TARGETS` 에 그
  디렉터리를 추가한다. 하네스 테스트(`tool/test/commit_gate_test.py`)는 `TEST_TARGETS` 를 읽어 픽스처를 만들므로 따로
  고칠 것은 없다.
