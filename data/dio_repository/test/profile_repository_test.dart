import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:test/test.dart';

import 'api_client_test.dart' show clientWith, respond;

Map<String, Object?> _profileJson({
  Object? description = '장기투자자였는데',
  Object? badge = 'https://example.test/badge/3.png',
  Object? createdAt,
  bool withCreatedAt = false,
}) =>
    {
      'id': 7,
      'loginType': 'kakao',
      'badge': badge,
      'nickname': '손절왕',
      'description': description,
      'point': '120',
      'insigniaShow': '[https://example.test/insignia/0.png]',
      'insigniaOwn': '[https://example.test/insignia/0.png, https://example.test/insignia/1.png]',
      'myArticleCount': 2,
      'myCommentCount': 5,
      if (withCreatedAt) 'createdAt': createdAt,
    };

Map<String, Object?> _articleJson({Object? thumbnail = 'https://example.test/t.png', Object? lossCut, bool withLossCut = true}) => {
      'id': 11,
      'board': 1,
      'thumbnail': thumbnail,
      'title': '반도체 물타기',
      'count': 30,
      'commentCount': 4,
      'createdAt': '2026-10-01T09:00:00.000Z',
      if (withLossCut) 'lossCut': lossCut,
    };

void main() {
  group('ProfileRepository', () {
    test('getProfile 은 /profile/ 을 읽고 숫자 문자열도 int 로 읽는다', () async {
      final adapter = respond(_profileJson(withCreatedAt: true, createdAt: '2026-09-01T00:00:00.000Z'));
      final repository = ProfileRepository(clientWith(adapter));

      final profile = await repository.getProfile();

      expect(adapter.last!.method, 'GET');
      expect(adapter.last!.uri.path, '/profile/');
      expect(profile, (
        id: 7,
        loginType: 'kakao',
        badge: 'https://example.test/badge/3.png',
        nickname: '손절왕',
        description: '장기투자자였는데',
        point: 120,
        insigniaShow: '[https://example.test/insignia/0.png]',
        insigniaOwn: '[https://example.test/insignia/0.png, https://example.test/insignia/1.png]',
        myArticleCount: 2,
        myCommentCount: 5,
        createdAt: '2026-09-01T00:00:00.000Z',
      ));
    });

    test('getProfile 의 소개·배지·가입일이 없으면 문자열 "null" 이 아니라 null 이다', () async {
      final repository = ProfileRepository(clientWith(respond(_profileJson(description: null, badge: null))));

      final profile = await repository.getProfile();

      expect(profile.description, isNull);
      expect(profile.badge, isNull);
      expect(profile.createdAt, isNull);
    });

    test('getProfile 응답 형식이 다르면 ApiFormatFailure 를 던진다', () async {
      final repository = ProfileRepository(clientWith(respond([_profileJson()])));

      await expectLater(repository.getProfile(), throwsA(isA<ApiFormatFailure>()));
    });

    test('profileEdit 은 /profile/edit/ 에 PATCH 로 보내고 profile_updated 면 끝난다', () async {
      final adapter = respond({'result': 'profile_updated', 'error': null});
      final repository = ProfileRepository(clientWith(adapter));

      await repository.profileEdit(nickname: '새닉', description: '소개', insignia: '{a, b}');

      expect(adapter.last!.method, 'PATCH');
      expect(adapter.last!.uri.path, '/profile/edit/');
      expect(adapter.last!.data, {'nickname': '새닉', 'description': '소개', 'insignia': '{a, b}'});
    });

    test('profileEdit 이 서버 error 를 받으면 ApiServerFailure, 다른 result 면 ApiFormatFailure 다', () async {
      final rejected = ProfileRepository(clientWith(respond({'result': null, 'error': 'nickname_duplicated'})));
      await expectLater(
        rejected.profileEdit(nickname: 'a', description: '', insignia: '{}'),
        throwsA(isA<ApiServerFailure>().having((e) => e.serverError, 'serverError', 'nickname_duplicated')),
      );

      final odd = ProfileRepository(clientWith(respond({'result': 'something', 'error': null})));
      await expectLater(
        odd.profileEdit(nickname: 'a', description: '', insignia: '{}'),
        throwsA(isA<ApiFormatFailure>()),
      );
    });

    test('getMyaccountArticle 은 /profile/myarticle/ 에 offset·limit 을 붙이고 손실액 원문을 정수로 읽는다', () async {
      final adapter = respond([
        _articleJson(lossCut: '1,250,000'),
        _articleJson(lossCut: 430000),
        _articleJson(withLossCut: false, thumbnail: null),
      ]);
      final repository = ProfileRepository(clientWith(adapter));

      final articles = await repository.getMyaccountArticle(offset: 10, limit: 10);

      expect(adapter.last!.uri.path, '/profile/myarticle/');
      expect(adapter.last!.uri.queryParameters, {'offset': '10', 'limit': '10'});
      expect(articles.map((a) => a.lossCut), [1250000, 430000, null]);
      expect(articles.first.thumbnail, 'https://example.test/t.png');
      expect(articles.last.thumbnail, isNull);
      expect(articles.first, (
        id: 11,
        board: 1,
        thumbnail: 'https://example.test/t.png',
        title: '반도체 물타기',
        count: 30,
        commentCount: 4,
        createdAt: '2026-10-01T09:00:00.000Z',
        lossCut: 1250000,
      ));
    });

    test('getMyaccountComment 는 /profile/mycomment/ 를 읽고 원문 글 제목·id 를 location 에서 꺼낸다', () async {
      final adapter = respond([
        {
          'id': 3,
          'board': 2,
          'content': '힘내요',
          'createdAt': '2026-10-02T09:00:00.000Z',
          'location': {'title': '코인 손절', 'articleId': '44'},
        },
      ]);
      final repository = ProfileRepository(clientWith(adapter));

      final comments = await repository.getMyaccountComment(offset: 0, limit: 10);

      expect(adapter.last!.uri.path, '/profile/mycomment/');
      expect(comments.single, (
        id: 3,
        board: 2,
        title: '코인 손절',
        content: '힘내요',
        createdAt: '2026-10-02T09:00:00.000Z',
        articleId: 44,
      ));
    });

    test('myaccountWithdrawal 은 /profile/withdrawal/ 에 DELETE 로 id 를 보내고 profile_withdrawal 이면 끝난다', () async {
      final adapter = respond({'result': 'profile_withdrawal', 'error': null});
      final repository = ProfileRepository(clientWith(adapter));

      await repository.myaccountWithdrawal(userId: 7);

      expect(adapter.last!.method, 'DELETE');
      expect(adapter.last!.uri.path, '/profile/withdrawal/');
      expect(adapter.last!.data, {'id': 7});
    });

    test('myaccountWithdrawal 이 다른 result 를 받으면 ApiFormatFailure 다', () async {
      final repository = ProfileRepository(clientWith(respond({'result': 'nope', 'error': null})));

      await expectLater(repository.myaccountWithdrawal(userId: 7), throwsA(isA<ApiFormatFailure>()));
    });

    test('약관·개인정보는 result 본문을 돌려준다', () async {
      final terms = respond({'result': '제1조 목적', 'error': null});
      expect(await ProfileRepository(clientWith(terms)).myaccountTerms(), '제1조 목적');
      expect(terms.last!.uri.path, '/information/terms');

      final privacy = respond({'result': '수집 항목', 'error': null});
      expect(await ProfileRepository(clientWith(privacy)).myaccountPrivacy(), '수집 항목');
      expect(privacy.last!.uri.path, '/information/privacy');
    });

    test('약관 응답에 error 가 있으면 그 문자열을 본문으로 돌려주지 않고 ApiServerFailure 를 던진다', () async {
      final repository = ProfileRepository(clientWith(respond({'result': null, 'error': 'not_found'})));

      await expectLater(repository.myaccountTerms(), throwsA(isA<ApiServerFailure>()));
    });
  });
}
