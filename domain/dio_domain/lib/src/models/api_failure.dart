/// 저장소가 던지는 유일한 실패 타입. 전송 오류·HTTP 오류·서버 `error` 응답·응답 모양 불일치를 한 계층으로 모은다.
/// 화면은 이 타입만 `switch` 하면 되고, 새 경우가 생기면 컴파일러가 누락을 알려 준다(sealed).
sealed class ApiFailure implements Exception {
  const ApiFailure();
}

/// 네트워크에 닿지 못했다(연결 거부·호스트 조회 실패·오프라인).
final class ApiOffline extends ApiFailure {
  const ApiOffline();

  @override
  String toString() => 'ApiOffline';
}

/// 연결·전송·수신 시간 초과.
final class ApiTimeout extends ApiFailure {
  const ApiTimeout();

  @override
  String toString() => 'ApiTimeout';
}

/// 서버가 2xx 가 아닌 상태 코드로 답했다. 본문에 `error` 가 있으면 [serverError] 에 보존한다.
final class ApiHttpFailure extends ApiFailure {
  const ApiHttpFailure({required this.status, this.serverError});

  final int status;
  final String? serverError;

  @override
  String toString() => 'ApiHttpFailure($status${serverError == null ? '' : ', $serverError'})';
}

/// 서버가 2xx 로 답했지만 봉투의 `error` 필드가 채워져 있다.
final class ApiServerFailure extends ApiFailure {
  const ApiServerFailure(this.serverError);

  final String serverError;

  @override
  String toString() => 'ApiServerFailure($serverError)';
}

/// 응답이 기대한 모양이 아니다(JSON 파싱 실패, 필드 타입 불일치, 성공 리터럴 불일치).
final class ApiFormatFailure extends ApiFailure {
  const ApiFormatFailure(this.detail);

  final String detail;

  @override
  String toString() => 'ApiFormatFailure($detail)';
}

/// 위 어디에도 속하지 않는 오류. 원인을 [cause] 에 보존한다.
final class ApiUnknown extends ApiFailure {
  const ApiUnknown(this.cause);

  final Object cause;

  @override
  String toString() => 'ApiUnknown($cause)';
}
