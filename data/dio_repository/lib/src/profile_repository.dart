import 'package:dio_repository/src/api_client.dart';
import 'package:dio_repository/src/json_fields.dart';

typedef ProfileType = ({
  int id,
  String loginType,

  /// 배지 이미지 URL. 없으면 null.
  String? badge,
  String nickname,

  /// 자기 소개. 입력한 적이 없으면 null.
  String? description,
  int point,
  String insigniaShow,
  String insigniaOwn,
  int myArticleCount,
  int myCommentCount,

  /// 가입 시각(ISO 8601). 서버가 추가하기 전에는 null.
  String? createdAt,
});

typedef ProfileArticleType = ({
  int id,
  int board,

  /// 첫 이미지 URL. 없으면 null.
  String? thumbnail,
  String title,
  int count,
  int commentCount,
  String createdAt,

  /// 손실액(원). 서버가 추가하기 전에는 null.
  int? lossCut,
});

typedef ProfileCommentType = ({
  int id,
  int board,
  String title,
  String content,
  String createdAt,
  int articleId,
});

/// 내 프로필·내 글·내 댓글·탈퇴, 그리고 약관·개인정보 처리방침 본문.
class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  Future<ProfileType> getProfile() async {
    final body = await _client.get('/profile/');
    return ApiClient.decode(() {
      final json = jsonMap(body);
      return (
        id: jsonInt(json['id']),
        loginType: jsonString(json['loginType']),
        badge: jsonStringOrNull(json['badge']),
        nickname: jsonString(json['nickname']),
        description: jsonStringOrNull(json['description']),
        point: jsonInt(json['point']),
        insigniaShow: jsonString(json['insigniaShow']),
        insigniaOwn: jsonString(json['insigniaOwn']),
        myArticleCount: jsonInt(json['myArticleCount']),
        myCommentCount: jsonInt(json['myCommentCount']),
        createdAt: jsonStringOrNull(json['createdAt']),
      );
    });
  }

  /// [insignia] 는 서버가 받는 원문 형식 그대로다(지금은 `Set.toString()` 의 `'{url1, url2}'`).
  Future<void> profileEdit({
    required String nickname,
    required String description,
    required String insignia,
  }) =>
      _client.expectResult(
        ApiMethod.patch,
        '/profile/edit/',
        data: {'nickname': nickname, 'description': description, 'insignia': insignia},
        result: 'profile_updated',
      );

  Future<List<ProfileArticleType>> getMyaccountArticle({required int offset, required int limit}) async {
    final body = await _client.get('/profile/myarticle/', query: {'offset': offset, 'limit': limit});
    return ApiClient.decode(() => [
          for (final item in jsonList(body))
            () {
              final json = jsonMap(item);
              return (
                id: jsonInt(json['id']),
                board: jsonInt(json['board']),
                thumbnail: jsonStringOrNull(json['thumbnail']),
                title: jsonString(json['title']),
                count: jsonInt(json['count']),
                commentCount: jsonInt(json['commentCount']),
                createdAt: jsonString(json['createdAt']),
                lossCut: jsonLossAmountOrNull(json['lossCut']),
              );
            }(),
        ]);
  }

  Future<List<ProfileCommentType>> getMyaccountComment({required int offset, required int limit}) async {
    final body = await _client.get('/profile/mycomment/', query: {'offset': offset, 'limit': limit});
    return ApiClient.decode(() => [
          for (final item in jsonList(body))
            () {
              final json = jsonMap(item);
              final location = jsonMap(json['location']);
              return (
                id: jsonInt(json['id']),
                board: jsonInt(json['board']),
                title: jsonString(location['title']),
                content: jsonString(json['content']),
                createdAt: jsonString(json['createdAt']),
                articleId: jsonInt(location['articleId']),
              );
            }(),
        ]);
  }

  Future<void> myaccountWithdrawal({required int userId}) => _client.expectResult(
        ApiMethod.delete,
        '/profile/withdrawal/',
        data: {'id': userId},
        result: 'profile_withdrawal',
      );

  /// 이용약관 본문.
  Future<String> myaccountTerms() => _document('/information/terms');

  /// 개인정보 처리방침 본문.
  Future<String> myaccountPrivacy() => _document('/information/privacy');

  Future<String> _document(String path) async {
    final result = await _client.command(ApiMethod.get, path);
    return ApiClient.decode(() => jsonString(result));
  }
}
