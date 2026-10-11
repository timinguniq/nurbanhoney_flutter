import 'dart:io';

import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:test/test.dart';

import 'api_client_test.dart' show clientWith, respond;

/// free(코인) 저장소는 nurban 과 같은 모양이다. 여기서는 다른 점(경로·게시판 값·성공 리터럴)만 확인한다.
void main() {
  group('FreeRepository', () {
    test('getFreeAll 은 /board/free/ 를 읽고 코인(board 2) 목록으로 읽는다', () async {
      final adapter = respond([
        {
          'id': 8,
          'thumbnail': null,
          'title': '비트 손절',
          'lossCut': '430000',
          'content': '본문',
          'commentCount': '1',
          'likeCount': 2,
          'createdAt': '2026-10-10T10:00:00.000Z',
          'myRating': null,
          'user': {'userId': 4, 'nickname': '코인러', 'badge': null, 'insignia': '[]'},
        },
      ]);

      final items = await FreeRepository(clientWith(adapter)).getFreeAll(flag: 0, articleId: -1, limit: 10);

      expect(adapter.last!.uri.path, '/board/free/');
      expect(adapter.last!.uri.queryParameters, {'flag': '0', 'articleId': '-1', 'limit': '10'});
      expect(items.single.board, 2);
      expect(items.single.lossCut, 430000);
      expect(items.single.myReaction, Reaction.none);
    });

    test('글 작성은 /board/free/article/ 로 보내고 freeboard_posted 만 성공이다', () async {
      final adapter = respond({'result': 'freeboard_posted', 'error': null});
      await FreeRepository(clientWith(adapter)).freeArticleCreate(
        title: '제목',
        uuid: 'u-1',
        lossCut: 430000,
        thumbnail: 'https://example.test/uploads/1.png',
        content: '본문',
      );
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.uri.path, '/board/free/article/');

      await expectLater(
        FreeRepository(clientWith(respond({'result': 'nurbanboard_posted', 'error': null}))).freeArticleCreate(
          title: '제목',
          uuid: 'u-1',
          lossCut: 1,
          thumbnail: 't',
          content: 'c',
        ),
        throwsA(isA<ApiFormatFailure>()),
      );
    });

    test('사진 업로드·삭제는 /board/free/article/upload/image 를 쓴다', () async {
      final dir = Directory.systemTemp.createTempSync('free_upload_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final image = File('${dir.path}/photo.jpg')..writeAsBytesSync([1]);

      final upload = respond({'result': '/uploads/c.jpg', 'error': null});
      expect(
        await FreeRepository(clientWith(upload)).freeImageUpload(uuid: 'u-1', image: image),
        'https://example.test/uploads/c.jpg',
      );
      expect(upload.last!.uri.path, '/board/free/article/upload/image');

      final delete = respond({'result': 'ok', 'error': null});
      await FreeRepository(clientWith(delete)).freeImageDelete(uuid: 'u-1');
      expect(delete.last!.method, 'DELETE');
      expect(delete.last!.uri.path, '/board/free/article/upload/image/');
    });
  });
}
