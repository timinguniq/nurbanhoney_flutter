import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:test/test.dart';

import 'api_client_test.dart' show FakeHttpClientAdapter, clientWith, jsonBody, respond;

Map<String, Object?> _row({
  Object? id = 1,
  Object? loss = 12480000,
  Object? likes = 128,
  Object? userId = 7,
  Object? badge = 'https://example.test/badge/1.png',
  Object? nickname = '손절왕',
  Object? insignia = '[https://example.test/insignia/0.png]',
}) =>
    {
      'id': id,
      'totalLossCut': loss,
      'totalLikeCount': likes,
      'user': {'userId': userId, 'badge': badge, 'nickname': nickname, 'insignia': insignia},
    };

void main() {
  group('RankRepository', () {
    test('getRanks 는 /rank 를 읽어 응답 순서대로 행을 만든다', () async {
      final adapter = respond([_row(), _row(id: 2, userId: 8, nickname: '둘째')]);
      final repository = RankRepository(clientWith(adapter));

      final ranks = await repository.getRanks();

      expect(adapter.last!.uri.path, '/rank');
      expect(ranks, hasLength(2));
      expect(ranks.first, (
        id: 1,
        totalLossCut: 12480000,
        totalLikeCount: 128,
        userId: 7,
        badge: 'https://example.test/badge/1.png',
        nickname: '손절왕',
        insignia: '[https://example.test/insignia/0.png]',
      ));
      expect(ranks.last.nickname, '둘째');
    });

    test('getRankTab 은 /rank/popup 에 offset·limit 을 붙인다', () async {
      final adapter = respond([_row()]);
      final repository = RankRepository(clientWith(adapter));

      await repository.getRankTab(offset: 0, limit: 3);

      expect(adapter.last!.uri.path, '/rank/popup');
      expect(adapter.last!.uri.queryParameters, {'offset': '0', 'limit': '3'});
    });

    test('숫자 필드는 숫자 문자열로 와도 int 로 읽는다', () async {
      final repository = RankRepository(clientWith(respond([
        _row(id: '3', loss: '5400000', likes: '54', userId: '9'),
      ])));

      final rank = (await repository.getRanks()).single;

      expect((rank.id, rank.totalLossCut, rank.totalLikeCount, rank.userId), (3, 5400000, 54, 9));
    });

    test('배지가 없으면 문자열 "null" 이 아니라 null 이다', () async {
      final repository = RankRepository(clientWith(respond([_row(badge: null)])));

      expect((await repository.getRanks()).single.badge, isNull);
    });

    test('휘장이 JSON 배열로 와도 기존 원문 형식(대괄호 목록)으로 읽는다', () async {
      final repository = RankRepository(clientWith(respond([
        _row(insignia: ['https://example.test/insignia/0.png', 'https://example.test/insignia/1.png']),
      ])));

      expect(
        (await repository.getRanks()).single.insignia,
        '[https://example.test/insignia/0.png, https://example.test/insignia/1.png]',
      );
    });

    test('빈 목록이면 빈 리스트다', () async {
      final repository = RankRepository(clientWith(respond([])));

      expect(await repository.getRanks(), isEmpty);
    });

    test('응답이 목록이 아니거나 필드 형식이 다르면 ApiFormatFailure 를 던진다', () async {
      final bodies = <Object?>[
        {'result': 'oops'},
        [_row(loss: 'many')],
        [_row(nickname: null)],
        [
          {'id': 1, 'totalLossCut': 1, 'totalLikeCount': 1},
        ],
      ];
      for (final body in bodies) {
        final repository = RankRepository(clientWith(respond(body)));

        await expectLater(repository.getRanks(), throwsA(isA<ApiFormatFailure>()), reason: '$body');
      }
    });

    test('HTTP 오류는 ApiHttpFailure 로 전달된다', () async {
      final repository = RankRepository(clientWith(
        FakeHttpClientAdapter((_) async => jsonBody({'error': 'down'}, status: 503)),
      ));

      await expectLater(
        repository.getRankTab(offset: 0, limit: 3),
        throwsA(isA<ApiHttpFailure>().having((e) => e.status, 'status', 503)),
      );
    });
  });
}
