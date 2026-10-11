import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:test/test.dart';

import 'api_client_test.dart' show clientWith, respond;

void main() {
  group('DioRepository.getLogin', () {
    test('/login 에 POST 로 로그인 수단·키를 보내고 토큰과 정수 userId 를 돌려준다', () async {
      final adapter = respond({'token': 'server-token', 'userId': '42'});

      final login = await DioRepository(clientWith(adapter)).getLogin(loginType: 'kakao', key: 'k', password: null);

      expect(login, (token: 'server-token', userId: 42));
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.uri.path, '/login');
      expect(adapter.last!.data, {'loginType': 'kakao', 'key': 'k', 'password': null});
    });

    test('서버가 error 를 주면 ApiServerFailure 다', () async {
      final repository = DioRepository(clientWith(respond({'error': 'invalid_key'})));

      await expectLater(
        repository.getLogin(loginType: 'kakao', key: 'k', password: null),
        throwsA(isA<ApiServerFailure>().having((e) => e.serverError, 'serverError', 'invalid_key')),
      );
    });

    test('토큰이 없거나 비었거나 userId 가 숫자가 아니면 ApiFormatFailure 다', () async {
      final bodies = <Object?>[
        {'userId': 42},
        {'token': '', 'userId': 42},
        {'token': 't', 'userId': 'null'},
        {'token': 't'},
        ['t', 42],
      ];
      for (final body in bodies) {
        final repository = DioRepository(clientWith(respond(body)));

        await expectLater(
          repository.getLogin(loginType: 'kakao', key: 'k', password: null),
          throwsA(isA<ApiFormatFailure>()),
          reason: '$body',
        );
      }
    });
  });
}
