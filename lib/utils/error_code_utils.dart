import 'package:dio_domain/dio_domain.dart';

/// 화면에 캡션으로 보여줄 짧은 오류 코드. 개발자용 메시지 자체는 화면에 노출하지 않는다.
/// 저장소는 [ApiFailure] 만 던진다(docs/adr/0001-api-failure-and-single-client.md). 그 밖의 오류는 추측하지 않는다.
String errorCodeOf(Object? error) => switch (error) {
      ApiOffline() => 'NET-OFFLINE',
      ApiTimeout() => 'NET-TIMEOUT',
      ApiHttpFailure(:final status) => 'HTTP-$status',
      ApiServerFailure() => 'SERVER',
      ApiFormatFailure() => 'FORMAT',
      ApiUnknown() => 'UNKNOWN',
      _ => 'UNKNOWN',
    };

/// 타임아웃·연결 끊김처럼 네트워크 상태 때문에 난 오류인지. 오프라인 배너 표시에 쓴다.
bool isNetworkError(Object? error) => error is ApiOffline || error is ApiTimeout;

/// HTTP 응답 오류의 상태 코드. HTTP 오류가 아니면 null.
int? httpStatusOf(Object? error) => error is ApiHttpFailure ? error.status : null;
