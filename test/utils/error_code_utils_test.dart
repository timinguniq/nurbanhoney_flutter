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

  group('ApiFailure 가 아닌 오류', () {
    test('Dio 메시지처럼 보이는 문자열·예외도 추측하지 않고 UNKNOWN 이다', () {
      expect(errorCodeOf('Exception: DioException [connection timeout]'), 'UNKNOWN');
      expect(errorCodeOf(Exception('status code of 404')), 'UNKNOWN');
      expect(errorCodeOf(null), 'UNKNOWN');
    });

    test('네트워크 오류도 HTTP 상태도 아니다', () {
      expect(isNetworkError('connection error'), isFalse);
      expect(httpStatusOf(Exception('status code of 404')), isNull);
      expect(httpStatusOf(null), isNull);
    });
  });
}
