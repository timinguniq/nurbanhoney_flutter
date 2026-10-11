import 'package:dio_domain/dio_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/utils/error_code_utils.dart';

void main() {
  group('ApiFailure', () {
    test('errorCodeOf 는 실패 종류마다 짧은 코드를 만든다', () {
      expect(errorCodeOf(const ApiOffline()), 'NET-OFFLINE');
      expect(errorCodeOf(const ApiTimeout()), 'NET-TIMEOUT');
      expect(errorCodeOf(const ApiHttpFailure(status: 404)), 'HTTP-404');
      expect(errorCodeOf(const ApiHttpFailure(status: 503, serverError: 'down')), 'HTTP-503');
      expect(errorCodeOf(const ApiServerFailure('not_owner')), 'SERVER');
      expect(errorCodeOf(const ApiFormatFailure('bad')), 'FORMAT');
      expect(errorCodeOf(const ApiUnknown('boom')), 'UNKNOWN');
    });

    test('서버 오류 문자열이 코드에 섞여 화면에 나오지 않는다', () {
      expect(errorCodeOf(const ApiServerFailure('connection error status code of 500')), 'SERVER');
      expect(errorCodeOf(const ApiUnknown('Failed host lookup')), 'UNKNOWN');
    });

    test('isNetworkError 는 오프라인·시간 초과만 네트워크 오류로 본다', () {
      expect(isNetworkError(const ApiOffline()), isTrue);
      expect(isNetworkError(const ApiTimeout()), isTrue);
      expect(isNetworkError(const ApiHttpFailure(status: 500)), isFalse);
      expect(isNetworkError(const ApiServerFailure('x')), isFalse);
    });

    test('httpStatusOf 는 ApiHttpFailure 의 상태 코드만 돌려준다', () {
      expect(httpStatusOf(const ApiHttpFailure(status: 404)), 404);
      expect(httpStatusOf(const ApiServerFailure('status code of 404')), isNull);
      expect(httpStatusOf(const ApiTimeout()), isNull);
    });
  });

  // 저장소는 DioException 을 Exception(e) 로 감싸 던지므로 문자열 형태로만 받는다.
  const timeout = 'Exception: DioException [connection timeout]: '
      'The request connection took longer than 0:00:05.000000';
  const receiveTimeout = 'Exception: DioException [receive timeout]: x';
  const offline = 'Exception: DioException [connection error]: '
      'The connection errored: Failed host lookup';
  const socket = 'Exception: SocketException: Network is unreachable';
  const notFound = 'Exception: DioException [bad response]: This exception was '
      'thrown because the response has a status code of 404 and '
      'RequestOptions.validateStatus was configured to throw';
  const serverError = 'DioException [bad response]: status code of 500';

  group('errorCodeOf', () {
    test('타임아웃은 NET-TIMEOUT 이다', () {
      expect(errorCodeOf(timeout), 'NET-TIMEOUT');
      expect(errorCodeOf(receiveTimeout), 'NET-TIMEOUT');
    });

    test('연결 오류·소켓 오류는 NET-OFFLINE 이다', () {
      expect(errorCodeOf(offline), 'NET-OFFLINE');
      expect(errorCodeOf(socket), 'NET-OFFLINE');
    });

    test('HTTP 응답 오류는 상태 코드를 붙인다', () {
      expect(errorCodeOf(notFound), 'HTTP-404');
      expect(errorCodeOf(serverError), 'HTTP-500');
    });

    test('상태 코드가 없는 응답 오류는 HTTP-ERR 이다', () {
      expect(errorCodeOf('DioException [bad response]: x'), 'HTTP-ERR');
    });

    test('알 수 없는 오류와 null 은 UNKNOWN 이다', () {
      expect(errorCodeOf('boom'), 'UNKNOWN');
      expect(errorCodeOf(null), 'UNKNOWN');
      expect(errorCodeOf(Exception('something')), 'UNKNOWN');
    });
  });

  group('isNetworkError', () {
    test('타임아웃과 연결 오류만 네트워크 오류로 본다', () {
      expect(isNetworkError(timeout), isTrue);
      expect(isNetworkError(offline), isTrue);
      expect(isNetworkError(notFound), isFalse);
      expect(isNetworkError('boom'), isFalse);
    });
  });

  group('httpStatusOf', () {
    test('HTTP 응답 오류의 상태 코드를 숫자로 돌려준다', () {
      expect(httpStatusOf(notFound), 404);
      expect(httpStatusOf(serverError), 500);
    });

    test('HTTP 오류가 아니면 null 이다', () {
      expect(httpStatusOf(timeout), isNull);
      expect(httpStatusOf('boom'), isNull);
      expect(httpStatusOf(null), isNull);
    });
  });
}
