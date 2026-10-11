import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 요청마다 Authorization 헤더를 기록하고, 그 토큰을 닉네임으로 담은 프로필을 돌려주는 가짜 서버.
class _ProfileServer implements HttpClientAdapter {
  final authorizations = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final authorization = options.headers['Authorization'] as String?;
    authorizations.add(authorization);
    if (authorization == null) {
      return ResponseBody.fromString(jsonEncode({'error': 'login_required'}), 401);
    }
    return ResponseBody.fromString(
      jsonEncode({
        'id': 7,
        'loginType': 'kakao',
        'badge': null,
        'nickname': authorization.substring('Bearer '.length),
        'description': null,
        'point': 0,
        'insigniaShow': '[]',
        'insigniaOwn': '[]',
        'myArticleCount': 0,
        'myCommentCount': 0,
      }),
      200,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('로그인·로그아웃·다른 계정 로그인 때마다 프로필을 그 시점의 토큰으로 다시 받는다', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = PreferenceStorage(plugin: await SharedPreferences.getInstance());
    final server = _ProfileServer();
    final container = ProviderContainer(overrides: [
      preferenceStorageProvider.overrideWith((ref) async => storage),
      apiHttpClientAdapterProvider.overrideWithValue(server),
    ]);
    addTearDown(container.dispose);
    // 화면처럼 구독을 유지해 autoDispose 로 사라지지 않게 한다.
    container.listen(getProfileProvider, (_, __) {});
    final auth = container.read(authenticationServiceProvider.notifier);

    // 로그아웃 상태: 토큰 없이 요청하고 서버가 거절한다.
    await expectLater(container.read(getProfileProvider.future), throwsA(isA<ApiHttpFailure>()));
    expect(server.authorizations, [null]);

    // 로그인(화면과 같은 순서: 토큰 저장 → 인증 상태 변경)
    await storage.setToken('first');
    auth.set(AuthenticationStatus.authenticated);
    expect((await container.read(getProfileProvider.future)).nickname, 'first');

    // 로그아웃(토큰 삭제 → 인증 상태 변경)
    await storage.setEmptyToken();
    auth.set(AuthenticationStatus.unauthenticated);
    await expectLater(container.read(getProfileProvider.future), throwsA(isA<ApiHttpFailure>()));

    // 다른 계정으로 로그인
    await storage.setToken('second');
    auth.set(AuthenticationStatus.authenticated);
    expect((await container.read(getProfileProvider.future)).nickname, 'second');

    expect(server.authorizations, [null, 'Bearer first', null, 'Bearer second']);
  });
}
