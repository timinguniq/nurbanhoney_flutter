import 'package:dio_domain/dio_domain.dart';

// 아래 정규식은 아직 ApiClient 로 옮기지 않은 저장소가 DioException 을 `Exception(e)` 로 감싸 던지는 경우만 쓴다.
// 모든 저장소가 ApiFailure 를 던지게 되면 삭제한다(docs/adr/0001-api-failure-and-single-client.md).
final _timeout = RegExp(r'(connection|receive|send) timeout');
final _offline = RegExp(
  r'connection error|SocketException|Network is unreachable|Failed host lookup',
);
final _status = RegExp(r'status code of (\d{3})');

/// 화면에 캡션으로 보여줄 짧은 오류 코드. 개발자용 메시지 자체는 화면에 노출하지 않는다.
String errorCodeOf(Object? error) {
  if (error is ApiFailure) {
    return switch (error) {
      ApiOffline() => 'NET-OFFLINE',
      ApiTimeout() => 'NET-TIMEOUT',
      ApiHttpFailure(:final status) => 'HTTP-$status',
      ApiServerFailure() => 'SERVER',
      ApiFormatFailure() => 'FORMAT',
      ApiUnknown() => 'UNKNOWN',
    };
  }
  final status = httpStatusOf(error);
  if (status != null) return 'HTTP-$status';
  final text = error?.toString() ?? '';
  if (_timeout.hasMatch(text)) return 'NET-TIMEOUT';
  if (_offline.hasMatch(text)) return 'NET-OFFLINE';
  if (text.contains('[bad response]')) return 'HTTP-ERR';
  return 'UNKNOWN';
}

/// 타임아웃·연결 끊김처럼 네트워크 상태 때문에 난 오류인지. 오프라인 배너 표시에 쓴다.
bool isNetworkError(Object? error) {
  final code = errorCodeOf(error);
  return code == 'NET-TIMEOUT' || code == 'NET-OFFLINE';
}

/// HTTP 응답 오류의 상태 코드. HTTP 오류가 아니면 null.
int? httpStatusOf(Object? error) {
  if (error is ApiFailure) return error is ApiHttpFailure ? error.status : null;
  final match = _status.firstMatch(error?.toString() ?? '');
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}
