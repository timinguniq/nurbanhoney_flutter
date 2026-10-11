# 아키텍처

nurbanhoney 는 세 레이어가 최상위 디렉터리로 나뉜 Flutter 모노레포다. 각 레이어는 `lib/` 의 하위 폴더가 아니라
독립 Dart/Flutter 패키지 모음이고, 루트 `pubspec.yaml` 이 `path:` 의존성으로 묶는다.

```
domain/       순수 모델·enum·typedef. Flutter/Riverpod import 없음.
data/         저장소: Dio HTTP 클라이언트, SharedPreferences 래퍼, 스트림.
application/  서비스: 저장소를 UI 에 노출하는 Riverpod Provider.
lib/          화면: nurbanhoney 앱 자체(루트 패키지 `nurbanhoney`), 기능별 폴더.
```

## 패키지

| 레이어 | 패키지 |
|---|---|
| domain | `authentication_domain`, `dio_domain`, `navigation_domain` |
| data | `authentication_repository`, `dio_repository`, `preference_storage`, `share_repository` |
| application | `authentication_service`, `dio_service`, `navigation_service`, `preference_storage_service`, `share_service` |
| app | `nurbanhoney` (루트, `lib/`) |

대부분의 도메인은 세 패키지 세트로 나뉜다: `domain/<이름>_domain`(모델) + `data/<이름>_repository`(입출력) +
`application/<이름>_service`(Riverpod Provider). 예: `authentication_*`, `dio_*`, `preference_storage*`.
새 데이터 소스를 추가할 때도 이 세트로 나누고 `lib/` 에 바로 넣지 않는다.

## 의존성 규칙

의존 방향은 `lib/` → `application/*` → `data/*` → `domain/*` 이고, 거꾸로 import 하지 않는다.

### 도구가 검사하는 규칙 (`tool/dep_guard.py`)

각 패키지 `lib/` 아래 `.dart` 파일의 `import`/`export` 문을 검사한다. `test/` 는 검사하지 않는다.

| 레이어 | import 금지 대상 | 위반 예 |
|---|---|---|
| domain | data, application, app 레이어 패키지 | `import 'package:dio_repository/dio_repository.dart';` |
| domain | Flutter: `flutter`, `flutter_*` 패키지, `dart:ui` | `import 'package:flutter/material.dart';` |
| domain | Riverpod: `riverpod`, `flutter_riverpod`, `hooks_riverpod`, `riverpod_annotation` | `import 'package:riverpod_annotation/riverpod_annotation.dart';` |
| data | application, app 레이어 패키지 | `import 'package:dio_service/dio_service.dart';` |
| application | app 레이어(`package:nurbanhoney/...`) | `import 'package:nurbanhoney/common/common.dart';` |
| 모든 레이어 | 패키지 `lib/` 밖으로 나가는 상대 경로 import | `import '../../data/x/lib/x.dart';` |

허용되는 예: data → domain, data → `flutter`(예: `preference_storage` 의 SharedPreferences), application → data·domain,
lib → 모든 레이어. 레이어 목록은 `domain/*/pubspec.yaml`, `data/*/pubspec.yaml`, `application/*/pubspec.yaml` 의
`name` 으로 자동으로 만든다. 패키지를 추가하면 따로 등록할 필요가 없다.

### 도구가 검사하지 않는 규칙 (리뷰로 확인)

- **레이어 건너뛰기:** `lib/` 가 `data/*` 를 직접 import 하는 것은 역방향이 아니라서 차단하지 않는다.
  지금 2곳이 있다: `lib/coin/view/coin_tab_page.dart`, `lib/stock/view/stock_tab_page.dart`(목록 레코드 타입
  `BoardAllType` 때문). 새 코드는 `application/*` 서비스를 거친다. 금지 규칙으로 바꿀지는 추후 결정한다.
- **domain pubspec 의 Flutter 의존성:** `authentication_domain`, `navigation_domain` 의 `pubspec.yaml` 에
  `flutter` 의존성이 선언돼 있다(`lib/` 에서 import 하지는 않는다). 정리할 때 함께 지운다.
- **상태 관리:** 새 화면·기능은 Riverpod(`flutter_riverpod` + `riverpod_annotation`)를 쓴다.
  `lib/common/viewmodel/base_viewmodel.dart` 의 `BaseViewModel`(ChangeNotifier)과 `lib/common/common/data_fetch_status.dart`
  는 레거시로, 주식·코인 탭 뷰모델만 쓴다. 확장하지 않고, 손대는 김에 Riverpod 로 옮긴다.
- **생성 파일:** `*.g.dart`, `*.freezed.dart` 는 커밋되어 있다. 손으로 고치지 않고, 애노테이션을 바꾸면
  `dart run build_runner build --delete-conflicting-outputs` 로 다시 만든다(루트와
  `application/authentication_service`, `application/navigation_service`).

## 진입점

`lib/main.dart` 는 `MobileAds`, `KakaoSdk`, `Firebase` 를 초기화하고 Android ID 를 가져온 뒤 `App` 을
`ProviderScope` 로 감싼다. `App` → `AppView`(`lib/app/view/app.dart`)는 `authenticationServiceProvider` 를 읽고,
지금은 인증 여부와 관계없이 `HomePageRefactor` 로 보낸다. 의도된 작업 중 상태이며, 확인 없이 고치지 않는다.
주석 처리된 `HomePage` 분기와 `/// 왜 인지 모르겠지만 SplashPage로 안 감` 메모가 진행 중인 리팩터링 영역을 표시한다.

## lib/ 기능 구조

기능 폴더(`home/`, `login/`, `ranking/`, `account/`, `article_detail/`, `article_create/`, `myaccount_setting/`,
`myaccount_edit/`, `coin/`, `stock/`)는 다음 구조를 따른다.

```
<feature>/
  <feature>.dart       # barrel export
  view/
    <feature>_page.dart
    view.dart          # barrel
    widgets/           # 기능 전용 위젯
```

공용 구성 요소는 `lib/common/`(정책 다이얼로그, `BaseViewModel`, `DataFetchStatus`)과 `lib/widgets/`, 날짜·손실액 형식 등
유틸리티는 `lib/utils/` 에 있다. 테마·색·글꼴·간격 토큰은 `lib/theme/nbk_*.dart`(`NbkTheme.light`, `NbkColors`,
`NbkTypography`, `NbkSpacing` 등)에 있고, 화면 문구는 `lib/l10n/strings.dart` 의 `Strings` 에 모은다.

## 백엔드

모든 HTTP 호출은 `data/dio_repository` 의 `ApiClient` 하나를 거친다(`docs/adr/0001-api-failure-and-single-client.md`).
`application/dio_service` 의 `apiClientProvider` 가 만들고, 저장소(`RankRepository`·`ProfileRepository`·
`NurbanRepository`·`FreeRepository`·`DioRepository`)는 생성자로 받는다.

- **인증:** 클라이언트가 요청할 때 `PreferenceStorage` 에서 토큰을 읽어 있을 때만 `Authorization: Bearer` 를 붙인다.
  저장소 메서드는 토큰을 받지 않는다.
- **실패:** 저장소는 `domain/dio_domain` 의 sealed `ApiFailure`(`ApiOffline`·`ApiTimeout`·`ApiHttpFailure`·
  `ApiServerFailure`·`ApiFormatFailure`·`ApiUnknown`)만 던진다. 서버의 `{result, error}` 봉투에서 `error` 가 오면
  `ApiServerFailure`, 기대한 성공 리터럴(`nurbanboard_deleted` 등)이 아니면 `ApiFormatFailure` 다. 화면은
  `lib/utils/error_code_utils.dart` 의 `errorCodeOf`·`isNetworkError`·`httpStatusOf` 로만 실패를 읽는다.
- **응답 타입:** 저장소가 응답 JSON 을 레코드로 한 번 읽는다(`json_fields.dart`). 없을 수 있는 값은 `null`(문자열 `'null'`
  이 아니다), 숫자는 `int`, 손실액은 원 단위 정수, 내 반응은 `Reaction`(용어는 `CONTEXT.md`).
- **타임아웃:** connect 5초·receive 10초, 사진 업로드만 receive 30초.

API 기본 URL 은 `domain/dio_domain/lib/src/models/dio_main_api.dart` 의 `DioMainApi.mainApi` 에 하드코딩되어 있다
(`https://nurbanhoney-api.devjj.co.kr`). 이 파일은 `domain/dio_domain/.gitignore` 로 제외되어 저장소에 없으므로
따로 받아 둔다. CI 는 더미 값을 쓴다.
인증 토큰과 기기 ID 는 `data/preference_storage` 를 통해 `SharedPreferences` 에 저장한다.

## 인증 흐름

로그인 화면(`lib/login/view/login_page.dart`)은 Kakao SDK 와 Firebase Google Sign-In 두 경로를 쓰고, 둘 다
`DioRepository.getLogin`(`getLoginProvider`)으로 서버 토큰을 받아 `PreferenceStorage` 에 저장한다. 저장소는 레거시
이메일/비밀번호 요청 형식(`password`)도 받지만 지금 화면에서는 쓰지 않는다(항상 `null`).

- **상태:** `AuthenticationService`(Riverpod `@riverpod` 클래스)가 `AuthenticationStatus` 를 갖는 값 칸이다.
  `AppView` 가 저장된 토큰이 있는지(`PreferenceStorage.hasToken()`)로 이 값을 맞춘다.
  `data/authentication_repository` 는 어디서도 쓰지 않는다.
- **세션 쓰기:** 로그인 화면은 토큰·userId 를 저장한 뒤 `authenticated` 로, 설정 화면의 로그아웃·탈퇴는 토큰을 지운 뒤
  `unauthenticated` 로 바꾼다.
- **다시 받기:** `apiClientProvider` 가 인증 상태를 `watch` 하므로 상태가 바뀌면 클라이언트와 그 위의 저장소·
  `FutureProvider` 가 다시 만들어져 새 토큰으로 다시 받는다(`application/dio_service/test/profile_service_test.dart`).
