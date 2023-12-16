import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';

class RankRepository {
  /// constructor
  RankRepository._privateConstructor();
  static final RankRepository _instance = RankRepository._privateConstructor();

  factory RankRepository(){
    return _instance;
  }

  final dio = Dio();

  Future<List<({int id, int totalLossCut, int totalLikeCount, int userId, String badge, String nickname, Object insignia})>> getRankTab({
    required int offset,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        '${DioApi.mainApi}/rank/popup',
        queryParameters: {
          'offset': offset, 'limit': limit,
        },
      );
      final result = <({int id, int totalLossCut, int totalLikeCount, int userId, String badge, String nickname, Object insignia})>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getRankTab response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        totalLossCut: int.parse(response.data[i]['totalLossCut'].toString()),
        totalLikeCount: int.parse(response.data[i]['totalLikeCount'].toString()),
        userId: int.parse(response.data[i]['user']['userId'].toString()),
        badge: response.data[i]['user']['badge'].toString(),
        nickname: response.data[i]['user']['nickname'].toString(),
        insignia: response.data[i]['user']['insignia'] as Object);
        // result.add(BoardModel.fromJson(response.data[i]));
        result.add(records);
      }
      log('getRankTab response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getRankTab error : $e');
      throw Exception(e);
    }
  }

  /// 너반꿀 리스트 조회
  Future<List<BoardAllType>> getRanks() async {
    try {
      final response = await dio.get(
        '${DioApi.mainApi}/rank',
      );
      final result = <BoardAllType>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getRanks response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        board: 1,
        thumbnail: response.data[i]['thumbnail'].toString(),
        title: response.data[i]['title'].toString(),
        lossCut: response.data[i]['lossCut'].toString(),
        content: response.data[i]['content'].toString(),
        commentCount: response.data[i]['commentCount'].toString(),
        likeCount: response.data[i]['likeCount'].toString(),
        createdAt: response.data[i]['createdAt'].toString(),
        nickname: response.data[i]['user']['nickname'].toString());
        // result.add(BoardModel.fromJson(response.data[i]));
        result.add(records);
      }
      log('getRanks response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getRanks error : $e');
      throw Exception(e);
    }
  }

}