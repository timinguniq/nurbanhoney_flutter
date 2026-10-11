import 'dart:io';

import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/src/api_client.dart';
import 'package:dio_repository/src/board_items.dart';
import 'package:dio_repository/src/json_fields.dart';

typedef NurbanArticle = ({
  int id,
  String uuid,

  /// 첨부 사진 URL. 없으면 null.
  String? thumbnail,
  String title,

  /// 손실액(원)
  int lossCut,
  String content,
  int count,
  int commentCount,
  int likeCount,
  int dislikeCount,
  String updatedAt,
  int userId,

  /// 글쓴이 배지 URL. 없으면 null.
  String? badge,
  String nickname,
  String insignia,

  /// 내 반응(로그인하지 않았으면 none)
  Reaction myReaction,
});

typedef NurbanComment = ({
  int id,
  String content,
  int userId,

  /// 댓글 쓴이 배지 URL. 없으면 null.
  String? badge,
  String nickname,
  String insignia
});

/// 주식 게시판(와이어 이름 nurban). 글 상세·반응·댓글·삭제는 코인 글도 이 저장소를 쓴다(기존 동작).
class NurbanRepository {
  NurbanRepository(this._client);

  final ApiClient _client;

  /// 글 상세. 로그인했으면 내 반응도 온다.
  Future<NurbanArticle> getNurbanArticle({required int articleId}) async {
    final body = await _client.get('/board/nurban/article', query: {'id': articleId});
    return ApiClient.decode(() {
      final json = jsonMap(body);
      return (
        id: jsonInt(json['id']),
        uuid: jsonString(json['uuid']),
        thumbnail: jsonStringOrNull(json['thumbnail']),
        title: jsonString(json['title']),
        lossCut: jsonLossAmount(json['lossCut']),
        content: jsonString(json['content']),
        count: jsonInt(json['count']),
        commentCount: jsonInt(json['commentCount']),
        likeCount: jsonInt(json['likeCount']),
        dislikeCount: jsonInt(json['dislikeCount']),
        updatedAt: jsonString(json['updatedAt']),
        userId: jsonInt(json['userId']),
        badge: jsonStringOrNull(json['badge']),
        nickname: jsonString(json['nickname']),
        insignia: jsonString(json['insignia']),
        myReaction: jsonReaction(json['myRating']),
      );
    });
  }

  /// 목록. [articleId] 는 커서(처음은 -1, 다음은 마지막 글 id)다.
  Future<List<BoardAllType>> getNurbanAll({
    required int flag,
    required int articleId,
    required int limit,
  }) async {
    final body = await _client.get('/board/nurban/', query: {'flag': flag, 'articleId': articleId, 'limit': limit});
    return boardItemsOf(body, board: 1);
  }

  Future<void> nurbanArticleDelete({required int articleId, required String uuid}) => _client.expectResult(
        ApiMethod.delete,
        '/board/nurban/article/',
        data: {'id': articleId, 'uuid': uuid},
        result: 'nurbanboard_deleted',
      );

  /// 좋아요. 새 좋아요 수를 돌려준다.
  Future<int> nurbanLikeCreate({required int articleId}) => _reaction(ApiMethod.post, 'like', articleId);

  /// 좋아요 취소. 새 좋아요 수를 돌려준다.
  Future<int> nurbanLikeDelete({required int articleId}) => _reaction(ApiMethod.delete, 'like', articleId);

  /// 싫어요. 새 싫어요 수를 돌려준다.
  Future<int> nurbanDislikeCreate({required int articleId}) => _reaction(ApiMethod.post, 'dislike', articleId);

  /// 싫어요 취소. 새 싫어요 수를 돌려준다.
  Future<int> nurbanDislikeDelete({required int articleId}) => _reaction(ApiMethod.delete, 'dislike', articleId);

  Future<int> _reaction(ApiMethod method, String kind, int articleId) async {
    final result = await _client.command(method, '/board/nurban/article/$kind/', data: {'articleId': articleId});
    return ApiClient.decode(() => jsonInt(result));
  }

  /// 사진 업로드. 절대 URL 을 돌려준다.
  Future<String> nurbanImageUpload({required String uuid, required File image}) =>
      uploadBoardImage(_client, '/board/nurban/article/upload/image', uuid: uuid, image: image);

  Future<void> nurbanImageDelete({required String uuid}) =>
      _client.command(ApiMethod.delete, '/board/nurban/article/upload/image/', data: {'uuid': uuid});

  Future<void> nurbanArticleCreate({
    required String title,
    required String uuid,
    required int lossCut,
    required String thumbnail,
    required String content,
  }) =>
      _client.expectResult(
        ApiMethod.post,
        '/board/nurban/article/',
        data: {'title': title, 'uuid': uuid, 'lossCut': lossCut, 'thumbnail': thumbnail, 'content': content},
        result: 'nurbanboard_posted',
      );

  /// 댓글 목록. [commentId] 는 커서(처음은 -1)다.
  Future<List<NurbanComment>> getNurbanComments({
    required int articleId,
    required int commentId,
    required int limit,
  }) async {
    final body = await _client.get(
      '/board/nurban/article/comment',
      query: {'articleId': articleId, 'commentId': commentId, 'limit': limit},
    );
    return ApiClient.decode(() => [
          for (final item in jsonList(body))
            () {
              final json = jsonMap(item);
              final user = jsonMap(json['user']);
              return (
                id: jsonInt(json['id']),
                content: jsonString(json['content']),
                userId: jsonInt(user['userId']),
                badge: jsonStringOrNull(user['badge']),
                nickname: jsonString(user['nickname']),
                insignia: jsonString(user['insignia']),
              );
            }(),
        ]);
  }

  /// 댓글 작성. 성공 result 값은 정해져 있지 않아 error 가 없으면 성공이다.
  Future<void> nurbanCommentCreate({required int articleId, required String content}) =>
      _client.command(ApiMethod.post, '/board/nurban/article/comment/', data: {'articleId': articleId, 'content': content});

  Future<void> nurbanCommentDelete({required int commentId, required int articleId}) => _client.expectResult(
        ApiMethod.delete,
        '/board/nurban/article/comment/',
        data: {'id': commentId, 'articleId': articleId},
        result: 'nurbancomment_deleted',
      );
}
