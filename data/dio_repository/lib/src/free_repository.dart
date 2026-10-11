import 'dart:io';

import 'package:dio_repository/src/api_client.dart';
import 'package:dio_repository/src/board_items.dart';

/// 코인 게시판(와이어 이름 free). 목록·작성·사진만 이 경로를 쓰고, 상세·반응·댓글·삭제는 [NurbanRepository] 를 쓴다
/// (기존 동작).
class FreeRepository {
  FreeRepository(this._client);

  final ApiClient _client;

  /// 목록. [articleId] 는 커서(처음은 -1, 다음은 마지막 글 id)다.
  Future<List<BoardAllType>> getFreeAll({
    required int flag,
    required int articleId,
    required int limit,
  }) async {
    final body = await _client.get('/board/free/', query: {'flag': flag, 'articleId': articleId, 'limit': limit});
    return boardItemsOf(body, board: 2);
  }

  /// 사진 업로드. 절대 URL 을 돌려준다.
  Future<String> freeImageUpload({required String uuid, required File image}) =>
      uploadBoardImage(_client, '/board/free/article/upload/image', uuid: uuid, image: image);

  Future<void> freeImageDelete({required String uuid}) =>
      _client.command(ApiMethod.delete, '/board/free/article/upload/image/', data: {'uuid': uuid});

  Future<void> freeArticleCreate({
    required String title,
    required String uuid,
    required int lossCut,
    required String thumbnail,
    required String content,
  }) =>
      _client.expectResult(
        ApiMethod.post,
        '/board/free/article/',
        data: {'title': title, 'uuid': uuid, 'lossCut': lossCut, 'thumbnail': thumbnail, 'content': content},
        result: 'freeboard_posted',
      );
}
