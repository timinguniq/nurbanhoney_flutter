---
status: accepted
date: 2026-10-11
---

# 저장소는 `ApiFailure` 하나만 던지고, 토큰은 HTTP 클라이언트가 붙인다

`data/dio_repository` 의 메서드 31개는 성공과 서버 오류를 같은 `String` 으로 돌려주고(`'nurbanboard_deleted'` 같은 성공
리터럴, 서버 `error` 문자열), 전송 오류는 `throw Exception(e)` 로 감싸며, null 필드는 `'null'` 문자열로 넘겼다. 그래서
화면 15곳과 테스트 가짜 9개가 결과 문자열 비교·`int.tryParse`·`startsWith('http')`·메시지 정규식(`error_code_utils`)·
`== 'null'` 검사로 저장소의 규칙을 다시 배우고 있었고, 그 규칙을 검증하는 테스트는 없었다.

결정: 저장소는 타입이 있는 값을 돌려주고(명령은 `Future<void>`·`Future<int>`·URL `String`), 실패는 `domain/dio_domain`
의 sealed `ApiFailure`(`ApiOffline`·`ApiTimeout`·`ApiHttpFailure`·`ApiServerFailure`·`ApiFormatFailure`·`ApiUnknown`)만
던진다. 성공 리터럴 검증은 저장소 안에서 한다. HTTP 호출은 `ApiClient` 하나를 거치고, 이 클라이언트가 세션의 토큰을 읽어
있을 때만 `Authorization` 을 붙이며 타임아웃·오류 분류·로그를 한곳에서 정한다. 저장소 메서드는 `token` 파라미터를
받지 않고, `apiClientProvider` 가 인증 상태를 `watch` 해 로그인·로그아웃 때 의존 사슬 전체를 다시 만든다.

## 고려한 대안

- **`Result<T, ApiFailure>` 반환**: 호출자가 매번 분기해야 한다. Riverpod 의 `AsyncValue` 가 이미 던져진 오류를 받는
  자리이고, 명령은 "안 던지면 성공" 이 가장 짧아서 throw 를 골랐다.
- **토큰 파라미터 유지 + 헤더 조립만 공통화**: 클라이언트가 하나이려면 인터셉터가 필요하고, 인터셉터가 있으면 토큰
  파라미터는 할 일이 없다. 토큰이 family 키에서 빠지는 대신 인증 상태 `watch` 로 무효화를 대신한다.
- **문자열 코드 체계 유지**: `errorCodeOf` 가 Dio 의 메시지 문구에 묶여 Dio 업그레이드가 인터페이스 변경이 됐다.

## 결과

- 토큰이 있으면 공개 엔드포인트(랭킹·약관·글 상세)에도 `Authorization` 이 붙는다. 서버가 거부하면 클라이언트에
  "인증 없음" 옵션을 추가한다. 부수 효과로 글 상세의 `myRating` 이 의미를 가져 반응 바의 이중 읽기가 사라진다.
- `data/dio_repository` 에 처음으로 테스트가 생기고, 커밋 게이트가 그 패키지 테스트도 실행한다.
- 레코드 필드 타입이 바뀐다: 숫자는 `int`, 없을 수 있는 값은 `String?`, 반응은 `Reaction` enum.
