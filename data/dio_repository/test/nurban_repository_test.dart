import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:test/test.dart';

import 'api_client_test.dart' show clientWith, respond;

Map<String, Object?> _listItem({
  Object? id = 5,
  Object? thumbnail = '/uploads/5.png',
  Object? lossCut = '1,250,000',
  Object? likeCount = '12',
  Object? badge = 'https://example.test/badge/1.png',
  Object? myRating = 'like',
}) =>
    {
      'id': id,
      'thumbnail': thumbnail,
      'title': '삼성 물타기',
      'lossCut': lossCut,
      'content': '본문',
      'commentCount': 3,
      'likeCount': likeCount,
      'createdAt': '2026-10-10T10:00:00.000Z',
      'myRating': myRating,
      'user': {'userId': '7', 'nickname': '손절왕', 'badge': badge, 'insignia': '[]'},
    };

Map<String, Object?> _article({Object? myRating = 'dislike', Object? thumbnail, Object? badge}) => {
      'id': 5,
      'uuid': 'u-5',
      'thumbnail': thumbnail,
      'title': '삼성 물타기',
      'lossCut': 1250000,
      'content': '본문',
      'count': '30',
      'commentCount': 3,
      'likeCount': 12,
      'dislikeCount': '2',
      'updatedAt': '2026-10-10T10:00:00.000Z',
      'userId': 7,
      'badge': badge,
      'nickname': '손절왕',
      'insignia': '[]',
      'myRating': myRating,
    };

void main() {
  group('NurbanRepository 읽기', () {
    test('getNurbanAll 은 /board/nurban/ 에 커서를 붙이고 주식(board 1) 목록으로 읽는다', () async {
      final adapter = respond([_listItem()]);
      final repository = NurbanRepository(clientWith(adapter));

      final items = await repository.getNurbanAll(flag: 0, articleId: -1, limit: 10);

      expect(adapter.last!.method, 'GET');
      expect(adapter.last!.uri.path, '/board/nurban/');
      expect(adapter.last!.uri.queryParameters, {'flag': '0', 'articleId': '-1', 'limit': '10'});
      expect(items.single, (
        id: 5,
        board: 1,
        thumbnail: '/uploads/5.png',
        title: '삼성 물타기',
        lossCut: 1250000,
        content: '본문',
        commentCount: 3,
        likeCount: 12,
        createdAt: '2026-10-10T10:00:00.000Z',
        userId: 7,
        nickname: '손절왕',
        badge: 'https://example.test/badge/1.png',
        insignia: '[]',
        myReaction: Reaction.like,
      ));
    });

    test('목록의 썸네일·배지가 없으면 null, 반응이 없거나 모르는 값이면 none 이다', () async {
      final repository = NurbanRepository(clientWith(respond([
        _listItem(thumbnail: null, badge: null, myRating: null),
        _listItem(id: 6, myRating: 'null'),
        _listItem(id: 7, myRating: 'dislike'),
      ])));

      final items = await repository.getNurbanAll(flag: 0, articleId: -1, limit: 10);

      expect(items.first.thumbnail, isNull);
      expect(items.first.badge, isNull);
      expect(items.map((i) => i.myReaction), [Reaction.none, Reaction.none, Reaction.dislike]);
    });

    test('목록 항목의 필수 필드 형식이 다르면 ApiFormatFailure 다', () async {
      final repository = NurbanRepository(clientWith(respond([_listItem(likeCount: 'many')])));

      await expectLater(
        repository.getNurbanAll(flag: 0, articleId: -1, limit: 10),
        throwsA(isA<ApiFormatFailure>()),
      );
    });

    test('getNurbanArticle 은 /board/nurban/article 에 id 를 붙이고 내 반응까지 읽는다', () async {
      final adapter = respond(_article(thumbnail: '/uploads/5.png'));
      final repository = NurbanRepository(clientWith(adapter));

      final article = await repository.getNurbanArticle(articleId: 5);

      expect(adapter.last!.uri.path, '/board/nurban/article');
      expect(adapter.last!.uri.queryParameters, {'id': '5'});
      expect(article, (
        id: 5,
        uuid: 'u-5',
        thumbnail: '/uploads/5.png',
        title: '삼성 물타기',
        lossCut: 1250000,
        content: '본문',
        count: 30,
        commentCount: 3,
        likeCount: 12,
        dislikeCount: 2,
        updatedAt: '2026-10-10T10:00:00.000Z',
        userId: 7,
        badge: null,
        nickname: '손절왕',
        insignia: '[]',
        myReaction: Reaction.dislike,
      ));
    });

    test('getNurbanComments 는 /board/nurban/article/comment 에 커서를 붙이고 작성자를 user 에서 읽는다', () async {
      final adapter = respond([
        {
          'id': 1,
          'content': '힘내요',
          'user': {'userId': '9', 'badge': null, 'nickname': '위로봇', 'insignia': '[]'},
        },
      ]);
      final repository = NurbanRepository(clientWith(adapter));

      final comments = await repository.getNurbanComments(articleId: 5, commentId: -1, limit: 10);

      expect(adapter.last!.uri.path, '/board/nurban/article/comment');
      expect(adapter.last!.uri.queryParameters, {'articleId': '5', 'commentId': '-1', 'limit': '10'});
      expect(comments.single, (id: 1, content: '힘내요', userId: 9, badge: null, nickname: '위로봇', insignia: '[]'));
    });
  });

  group('NurbanRepository 명령', () {
    test('좋아요·싫어요 생성·취소는 각 경로로 articleId 를 보내고 새 수를 int 로 돌려준다', () async {
      final cases = <(Future<int> Function(NurbanRepository), String, String)>[
        ((r) => r.nurbanLikeCreate(articleId: 5), 'POST', '/board/nurban/article/like/'),
        ((r) => r.nurbanLikeDelete(articleId: 5), 'DELETE', '/board/nurban/article/like/'),
        ((r) => r.nurbanDislikeCreate(articleId: 5), 'POST', '/board/nurban/article/dislike/'),
        ((r) => r.nurbanDislikeDelete(articleId: 5), 'DELETE', '/board/nurban/article/dislike/'),
      ];
      for (final (call, method, path) in cases) {
        final adapter = respond({'result': '13', 'error': null});

        expect(await call(NurbanRepository(clientWith(adapter))), 13, reason: '$method $path');
        expect(adapter.last!.method, method);
        expect(adapter.last!.uri.path, path);
        expect(adapter.last!.data, {'articleId': 5});
      }
    });

    test('좋아요가 숫자가 아닌 result 를 받으면 ApiFormatFailure, error 를 받으면 ApiServerFailure 다', () async {
      await expectLater(
        NurbanRepository(clientWith(respond({'result': 'already', 'error': null}))).nurbanLikeCreate(articleId: 5),
        throwsA(isA<ApiFormatFailure>()),
      );
      await expectLater(
        NurbanRepository(clientWith(respond({'result': null, 'error': 'login_required'}))).nurbanLikeCreate(articleId: 5),
        throwsA(isA<ApiServerFailure>()),
      );
    });

    test('글 삭제는 /board/nurban/article/ 에 DELETE 로 id·uuid 를 보내고 nurbanboard_deleted 만 성공이다', () async {
      final adapter = respond({'result': 'nurbanboard_deleted', 'error': null});
      await NurbanRepository(clientWith(adapter)).nurbanArticleDelete(articleId: 5, uuid: 'u-5');

      expect(adapter.last!.method, 'DELETE');
      expect(adapter.last!.uri.path, '/board/nurban/article/');
      expect(adapter.last!.data, {'id': 5, 'uuid': 'u-5'});

      await expectLater(
        NurbanRepository(clientWith(respond({'result': 'nope', 'error': null})))
            .nurbanArticleDelete(articleId: 5, uuid: 'u-5'),
        throwsA(isA<ApiFormatFailure>()),
      );
    });

    test('글 작성은 /board/nurban/article/ 에 POST 로 보내고 nurbanboard_posted 만 성공이다', () async {
      final adapter = respond({'result': 'nurbanboard_posted', 'error': null});
      await NurbanRepository(clientWith(adapter)).nurbanArticleCreate(
        title: '제목',
        uuid: 'u-1',
        lossCut: 1250000,
        thumbnail: 'https://example.test/uploads/1.png',
        content: '본문',
      );

      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.uri.path, '/board/nurban/article/');
      expect(adapter.last!.data, {
        'title': '제목',
        'uuid': 'u-1',
        'lossCut': 1250000,
        'thumbnail': 'https://example.test/uploads/1.png',
        'content': '본문',
      });

      await expectLater(
        NurbanRepository(clientWith(respond({'result': 'freeboard_posted', 'error': null}))).nurbanArticleCreate(
          title: '제목',
          uuid: 'u-1',
          lossCut: 1,
          thumbnail: 't',
          content: 'c',
        ),
        throwsA(isA<ApiFormatFailure>()),
      );
    });

    test('댓글 작성은 POST, 삭제는 DELETE 로 /board/nurban/article/comment/ 에 보낸다', () async {
      final create = respond({'result': 'ok', 'error': null});
      await NurbanRepository(clientWith(create)).nurbanCommentCreate(articleId: 5, content: '힘내요');
      expect(create.last!.method, 'POST');
      expect(create.last!.uri.path, '/board/nurban/article/comment/');
      expect(create.last!.data, {'articleId': 5, 'content': '힘내요'});

      final delete = respond({'result': 'nurbancomment_deleted', 'error': null});
      await NurbanRepository(clientWith(delete)).nurbanCommentDelete(commentId: 3, articleId: 5);
      expect(delete.last!.method, 'DELETE');
      expect(delete.last!.uri.path, '/board/nurban/article/comment/');
      expect(delete.last!.data, {'id': 3, 'articleId': 5});
    });

    test('댓글 작성이 서버 error 를 받으면 성공으로 넘기지 않고 ApiServerFailure 를 던진다', () async {
      final repository = NurbanRepository(clientWith(respond({'result': null, 'error': 'too_long'})));

      await expectLater(
        repository.nurbanCommentCreate(articleId: 5, content: 'x'),
        throwsA(isA<ApiServerFailure>()),
      );
    });

    test('댓글 삭제가 nurbancomment_deleted 가 아니면 ApiFormatFailure 다', () async {
      final repository = NurbanRepository(clientWith(respond({'result': 'nope', 'error': null})));

      await expectLater(repository.nurbanCommentDelete(commentId: 3, articleId: 5), throwsA(isA<ApiFormatFailure>()));
    });
  });

  group('NurbanRepository 사진', () {
    late Directory dir;
    late File image;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('nurban_upload_test');
      image = File('${dir.path}/photo.jpg')..writeAsBytesSync([1, 2, 3]);
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('업로드는 uuid 와 이미지를 multipart 로 보내고 서버 경로 앞에 기본 URL 을 붙여 돌려준다', () async {
      final adapter = respond({'result': '/uploads/u-1.jpg', 'error': null});

      final url = await NurbanRepository(clientWith(adapter)).nurbanImageUpload(uuid: 'u-1', image: image);

      expect(url, 'https://example.test/uploads/u-1.jpg');
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.uri.path, '/board/nurban/article/upload/image');
      expect(adapter.last!.receiveTimeout, ApiClient.uploadReceiveTimeout);
      final form = adapter.last!.data as FormData;
      expect([for (final f in form.fields) (f.key, f.value)], [('uuid', 'u-1')]);
      expect(form.files.single.key, 'image');
    });

    test('업로드가 서버 error 를 받으면 그 문자열을 URL 로 돌려주지 않고 ApiServerFailure 를 던진다', () async {
      final repository = NurbanRepository(clientWith(respond({'result': null, 'error': 'too_large'})));

      await expectLater(repository.nurbanImageUpload(uuid: 'u-1', image: image), throwsA(isA<ApiServerFailure>()));
    });

    test('업로드 result 가 비어 있으면 ApiFormatFailure 다', () async {
      final repository = NurbanRepository(clientWith(respond({'result': '', 'error': null})));

      await expectLater(repository.nurbanImageUpload(uuid: 'u-1', image: image), throwsA(isA<ApiFormatFailure>()));
    });

    test('이미지 파일을 읽지 못하면 ApiFailure(ApiUnknown) 로 던진다', () async {
      final repository = NurbanRepository(clientWith(respond({'result': '/x', 'error': null})));

      await expectLater(
        repository.nurbanImageUpload(uuid: 'u-1', image: File('${dir.path}/missing.jpg')),
        throwsA(isA<ApiUnknown>()),
      );
    });

    test('사진 삭제는 /board/nurban/article/upload/image/ 에 DELETE 로 uuid 를 보낸다', () async {
      final adapter = respond({'result': 'ok', 'error': null});

      await NurbanRepository(clientWith(adapter)).nurbanImageDelete(uuid: 'u-1');

      expect(adapter.last!.method, 'DELETE');
      expect(adapter.last!.uri.path, '/board/nurban/article/upload/image/');
      expect(adapter.last!.data, {'uuid': 'u-1'});
    });
  });
}
