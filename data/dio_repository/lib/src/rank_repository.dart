import 'package:dio_repository/src/api_client.dart';
import 'package:dio_repository/src/json_fields.dart';

/// 랭킹 한 행. 순위는 응답 순서(index + 1)이고 필드에 없다.
typedef RankType = ({
  int id,
  int totalLossCut,
  int totalLikeCount,
  int userId,

  /// 배지 이미지 URL. 없으면 null.
  String? badge,
  String nickname,

  /// 휘장 목록 원문(예: `[url1, url2]`). share_service 의 `convertToInsignia` 로 푼다.
  String insignia,
});

/// 손실 랭킹. 서버가 집계 기간(월) 전체를 한 번에 준다.
class RankRepository {
  RankRepository(this._client);

  final ApiClient _client;

  /// 앞쪽 일부(홈 Top3).
  Future<List<RankType>> getRankTab({required int offset, required int limit}) async =>
      _ranksOf(await _client.get('/rank/popup', query: {'offset': offset, 'limit': limit}));

  /// 전체 랭킹(랭킹 탭).
  Future<List<RankType>> getRanks() async => _ranksOf(await _client.get('/rank'));

  static List<RankType> _ranksOf(Object? body) => ApiClient.decode(() => [
        for (final item in jsonList(body)) _rankOf(jsonMap(item)),
      ]);

  static RankType _rankOf(Map<String, Object?> json) {
    final user = jsonMap(json['user']);
    return (
      id: jsonInt(json['id']),
      totalLossCut: jsonInt(json['totalLossCut']),
      totalLikeCount: jsonInt(json['totalLikeCount']),
      userId: jsonInt(user['userId']),
      badge: jsonStringOrNull(user['badge']),
      nickname: jsonString(user['nickname']),
      insignia: jsonString(user['insignia']),
    );
  }
}
