import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:test/test.dart';

/// 네트워크 대신 응답을 만들어 주는 가짜 어댑터. 마지막 요청을 [last] 에 남긴다.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object? body, {int status = 200}) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

FakeHttpClientAdapter respond(Object? body, {int status = 200}) =>
    FakeHttpClientAdapter((_) async => jsonBody(body, status: status));

ApiClient clientWith(FakeHttpClientAdapter adapter, {Future<String?> Function()? readToken}) =>
    ApiClient(
      baseUrl: 'https://example.test',
      readToken: readToken ?? () async => null,
      adapter: adapter,
    );

void main() {
  group('ApiClient', () {
    test('GET 은 JSON 본문을 돌려주고 경로는 baseUrl 뒤에 붙는다', () async {
      final adapter = respond([
        {'id': 1}
      ]);
      final client = clientWith(adapter);

      final body = await client.get('/rank/', query: {'offset': 0, 'limit': 3});

      expect(body, [
        {'id': 1}
      ]);
      expect(adapter.last!.uri.toString(), 'https://example.test/rank/?offset=0&limit=3');
      expect(adapter.last!.method, 'GET');
    });

    test('토큰이 있으면 Authorization 헤더를 붙인다', () async {
      final adapter = respond({});
      final client = clientWith(adapter, readToken: () async => 'abc');

      await client.get('/profile/');

      expect(adapter.last!.headers['Authorization'], 'Bearer abc');
    });

    test('토큰이 없거나 비어 있으면 Authorization 헤더를 붙이지 않는다', () async {
      for (final token in <String?>[null, '']) {
        final adapter = respond({});
        final client = clientWith(adapter, readToken: () async => token);

        await client.get('/rank/');

        expect(adapter.last!.headers.containsKey('Authorization'), isFalse, reason: 'token=$token');
      }
    });

    test('토큰 읽기가 실패하면 ApiUnknown 을 던진다', () async {
      final client = clientWith(respond({}), readToken: () async => throw StateError('storage'));

      await expectLater(client.get('/rank/'), throwsA(isA<ApiUnknown>()));
    });

    test('request 는 본문을 JSON 으로 보내고 메서드를 지킨다', () async {
      final adapter = respond({'result': 'ok', 'error': null});
      final client = clientWith(adapter);

      await client.request(ApiMethod.delete, '/board/nurban/article/', data: {'id': 7});

      expect(adapter.last!.method, 'DELETE');
      expect(adapter.last!.data, {'id': 7});
    });

    test('기본 타임아웃은 connect 5초·receive 10초이고 요청별로 receive 를 늘릴 수 있다', () async {
      final adapter = respond({});
      final client = clientWith(adapter);

      await client.get('/rank/');
      expect(adapter.last!.connectTimeout, const Duration(seconds: 5));
      expect(adapter.last!.receiveTimeout, const Duration(seconds: 10));

      await client.request(ApiMethod.post, '/upload', receiveTimeout: const Duration(seconds: 30));
      expect(adapter.last!.receiveTimeout, const Duration(seconds: 30));
    });

    group('command', () {
      test('error 가 비어 있으면 result 를 돌려준다', () async {
        final client = clientWith(respond({'result': 12, 'error': null}));

        expect(await client.command(ApiMethod.post, '/like'), 12);
      });

      test('error 가 있으면 ApiServerFailure 를 던진다', () async {
        final client = clientWith(respond({'result': null, 'error': 'not_owner'}));

        await expectLater(
          client.command(ApiMethod.delete, '/article'),
          throwsA(isA<ApiServerFailure>().having((e) => e.serverError, 'serverError', 'not_owner')),
        );
      });

      test('응답이 봉투 모양이 아니면 ApiFormatFailure 를 던진다', () async {
        final client = clientWith(respond([1, 2]));

        await expectLater(client.command(ApiMethod.post, '/like'), throwsA(isA<ApiFormatFailure>()));
      });
    });

    group('expectResult', () {
      test('result 가 기대한 성공 리터럴이면 정상 종료한다', () async {
        final client = clientWith(respond({'result': 'nurbanboard_deleted', 'error': null}));

        await client.expectResult(ApiMethod.delete, '/article', result: 'nurbanboard_deleted');
      });

      test('result 가 다르면 ApiFormatFailure 를 던진다', () async {
        final client = clientWith(respond({'result': 'something_else', 'error': null}));

        await expectLater(
          client.expectResult(ApiMethod.delete, '/article', result: 'nurbanboard_deleted'),
          throwsA(isA<ApiFormatFailure>().having((e) => e.detail, 'detail', contains('something_else'))),
        );
      });
    });

    group('실패 분류', () {
      test('2xx 가 아닌 응답은 ApiHttpFailure 이고 본문의 error 를 보존한다', () async {
        final client = clientWith(respond({'error': 'not_found'}, status: 404));

        await expectLater(
          client.get('/article/9'),
          throwsA(isA<ApiHttpFailure>()
              .having((e) => e.status, 'status', 404)
              .having((e) => e.serverError, 'serverError', 'not_found')),
        );
      });

      test('본문이 JSON 봉투가 아닌 HTTP 오류는 serverError 가 null 이다', () async {
        final adapter = FakeHttpClientAdapter(
          (_) async => ResponseBody.fromString('<html>Bad Gateway</html>', 502),
        );
        final client = clientWith(adapter);

        await expectLater(
          client.get('/rank/'),
          throwsA(isA<ApiHttpFailure>()
              .having((e) => e.status, 'status', 502)
              .having((e) => e.serverError, 'serverError', isNull)),
        );
      });

      test('성공 응답의 본문이 깨진 JSON 이면 ApiFormatFailure 이다', () async {
        final client = clientWith(FakeHttpClientAdapter((_) async => ResponseBody.fromString(
              '{invalid',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            )));

        await expectLater(client.get('/rank/'), throwsA(isA<ApiFormatFailure>()));
      });

      test('오류 응답의 본문이 깨진 JSON 이어도 상태 코드를 보존한다', () async {
        final client = clientWith(FakeHttpClientAdapter((_) async => ResponseBody.fromString(
              '{invalid',
              502,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            )));

        await expectLater(
          client.get('/rank/'),
          throwsA(isA<ApiHttpFailure>()
              .having((e) => e.status, 'status', 502)
              .having((e) => e.serverError, 'serverError', isNull)),
        );
      });

      test('성공 응답의 본문이 비어 있으면 null 을 돌려준다', () async {
        final client = clientWith(FakeHttpClientAdapter((_) async => ResponseBody.fromString('', 204)));

        expect(await client.get('/rank/'), isNull);
      });

      test('시간 초과는 ApiTimeout 이다', () async {
        for (final type in [
          DioExceptionType.connectionTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.receiveTimeout,
        ]) {
          final client = clientWith(FakeHttpClientAdapter(
            (options) => throw DioException(requestOptions: options, type: type),
          ));

          await expectLater(client.get('/rank/'), throwsA(isA<ApiTimeout>()), reason: '$type');
        }
      });

      test('연결 실패와 SocketException 은 ApiOffline 이다', () async {
        final cases = <DioException Function(RequestOptions)>[
          (o) => DioException(requestOptions: o, type: DioExceptionType.connectionError),
          (o) => DioException(
                requestOptions: o,
                type: DioExceptionType.unknown,
                error: const SocketException('Failed host lookup'),
              ),
        ];
        for (final make in cases) {
          final client = clientWith(FakeHttpClientAdapter((options) => throw make(options)));

          await expectLater(client.get('/rank/'), throwsA(isA<ApiOffline>()));
        }
      });

      test('그 밖의 오류는 ApiUnknown 이고 원인을 보존한다', () async {
        final client = clientWith(FakeHttpClientAdapter((_) => throw StateError('boom')));

        await expectLater(
          client.get('/rank/'),
          throwsA(isA<ApiUnknown>().having((e) => e.cause, 'cause', isA<StateError>())),
        );
      });
    });

    group('decode', () {
      test('파싱이 성공하면 값을 돌려준다', () {
        expect(ApiClient.decode(() => (<String, Object?>{'id': 3})['id'] as int), 3);
      });

      test('타입 불일치·형식 오류는 ApiFormatFailure 로 바꾼다', () {
        expect(
          () => ApiClient.decode(() => (<String, Object?>{'id': 'x'})['id'] as int),
          throwsA(isA<ApiFormatFailure>()),
        );
        expect(
          () => ApiClient.decode(() => int.parse('x')),
          throwsA(isA<ApiFormatFailure>()),
        );
      });

      test('이미 ApiFailure 인 오류는 그대로 던진다', () {
        expect(
          () => ApiClient.decode(() => throw const ApiServerFailure('keep')),
          throwsA(isA<ApiServerFailure>()),
        );
      });
    });
  });
}
