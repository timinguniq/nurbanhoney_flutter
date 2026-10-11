import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/src/api_client.dart';
import 'package:dio_repository/src/json_fields.dart';

/// 게시판 목록의 글 한 건. nurban(주식)·free(코인) 목록이 같은 모양이다.
typedef BoardAllType = ({
  int id,

  /// 1 주식, 2 코인(CONTEXT.md "게시판")
  int board,

  /// 첫 사진 URL. 없으면 null.
  String? thumbnail,
  String title,

  /// 손실액(원)
  int lossCut,
  String content,
  int commentCount,
  int likeCount,
  String createdAt,

  /// 글쓴이
  int userId,
  String nickname,

  /// 글쓴이 배지 URL. 없으면 null.
  String? badge,
  String insignia,

  /// 내 반응(로그인하지 않았으면 none)
  Reaction myReaction,
});

/// 목록 응답을 [BoardAllType] 으로 읽는다. 게시판 값은 응답에 없어 부르는 저장소가 넘긴다.
List<BoardAllType> boardItemsOf(Object? body, {required int board}) => ApiClient.decode(() => [
      for (final item in jsonList(body))
        () {
          final json = jsonMap(item);
          final user = jsonMap(json['user']);
          return (
            id: jsonInt(json['id']),
            board: board,
            thumbnail: jsonStringOrNull(json['thumbnail']),
            title: jsonString(json['title']),
            lossCut: jsonLossAmount(json['lossCut']),
            content: jsonString(json['content']),
            commentCount: jsonInt(json['commentCount']),
            likeCount: jsonInt(json['likeCount']),
            createdAt: jsonString(json['createdAt']),
            userId: jsonInt(user['userId']),
            nickname: jsonString(user['nickname']),
            badge: jsonStringOrNull(user['badge']),
            insignia: jsonString(user['insignia']),
            myReaction: jsonReaction(json['myRating']),
          );
        }(),
    ]);

/// 사진 한 장을 [path] 로 올리고 절대 URL 을 돌려준다. 서버는 상대 경로를 `result` 로 준다.
/// 파일을 읽지 못한 오류도 저장소 계약대로 [ApiFailure](ApiUnknown) 로 바꾼다.
Future<String> uploadBoardImage(
  ApiClient client,
  String path, {
  required String uuid,
  required File image,
}) async {
  final FormData form;
  try {
    form = FormData.fromMap({
      'uuid': uuid,
      'image': await MultipartFile.fromFile(image.path),
    });
  } catch (e) {
    throw ApiUnknown(e);
  }
  final result = await client.command(
    ApiMethod.post,
    path,
    data: form,
    receiveTimeout: ApiClient.uploadReceiveTimeout,
  );
  final relative = ApiClient.decode(() => jsonString(result));
  if (relative.isEmpty) throw const ApiFormatFailure('empty upload path');
  return '${client.baseUrl}$relative';
}
