import 'dart:typed_data';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio/dio.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 요청을 기록하고 빈 JSON 객체로 답하는 가짜 어댑터.
class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

/// 저장소를 [seed] 로 준비한 뒤 [apiClientProvider] 로 요청 하나를 보내고, 나간 요청을 돌려준다.
/// [preferenceStorageProvider] 를 붙잡는 다른 listener 는 두지 않는다(앱에서 다른 화면이 붙잡지 않아도 동작해야 한다).
Future<RequestOptions> _sendWith(Future<void> Function(PreferenceStorage storage) seed) async {
  SharedPreferences.setMockInitialValues({});
  final storage = PreferenceStorage(plugin: await SharedPreferences.getInstance());
  await seed(storage);
  final adapter = _RecordingAdapter();
  final container = ProviderContainer(overrides: [
    // 실제 SharedPreferences.getInstance() 처럼 비동기로 값을 준다.
    preferenceStorageProvider.overrideWith((ref) async {
      await Future<void>.delayed(const Duration(milliseconds: 1));
      return storage;
    }),
    apiHttpClientAdapterProvider.overrideWithValue(adapter),
  ]);
  addTearDown(container.dispose);

  await container.read(apiClientProvider).get('/rank/');

  return adapter.last!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('apiClientProvider', () {
    test('인증 상태가 바뀌면 클라이언트를 다시 만들고, 그 위에 선 provider 도 다시 계산된다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var builds = 0;
      final dependent = Provider((ref) {
        builds++;
        return ref.watch(apiClientProvider);
      });
      final subscription = container.listen(dependent, (_, __) {});
      final first = subscription.read();

      expect(container.read(apiClientProvider), same(first), reason: '상태가 그대로면 같은 클라이언트');

      container.read(authenticationServiceProvider.notifier).set(AuthenticationStatus.authenticated);

      expect(subscription.read(), isNot(same(first)));
      expect(builds, 2);
    });

    test('저장소에 토큰이 있으면 Authorization 헤더를 붙인다', () async {
      final request = await _sendWith((storage) => storage.setToken('abc'));

      expect(request.headers['Authorization'], 'Bearer abc');
    });

    test('토큰을 지운 상태(빈 토큰)면 Authorization 헤더를 붙이지 않는다', () async {
      final request = await _sendWith((storage) => storage.setEmptyToken());

      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('토큰을 저장한 적이 없으면 Authorization 헤더를 붙이지 않는다', () async {
      final request = await _sendWith((_) async {});

      expect(request.headers.containsKey('Authorization'), isFalse);
    });
  });
}
