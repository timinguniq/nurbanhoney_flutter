import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';


typedef BoardAllType = ({int id, int board, String? thumbnail,
  String title, String lossCut, String content, int commentCount, String likeCount, String createdAt,
  String authorId ,String nickname, String badge, String insignia, String myRating});

typedef LoginType = ({String token, String userId});

class DioRepository {
  /// constructor
  DioRepository._privateConstructor();
  static final DioRepository _instance = DioRepository._privateConstructor();

  factory DioRepository(){
    return _instance;
  }

  final dio = Dio();

  Future<List<({int id, int type, String name, String address})>> getBoard() async {
    try {
      final response = await dio.get('${DioApi.mainApi}/board');
      final result = <({int id, int type, String name, String address})>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getBoard response: ${response.data[i]}');
        final records =
          (id: int.parse(response.data[i]['id'].toString()),
          type: int.parse(response.data[i]['type'].toString()),
          name: response.data[i]['name'].toString(),
          address: response.data[i]['address'].toString());
       // result.add(BoardModel.fromJson(response.data[i]));
        result.add(records);
      }
      log('getBoard response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getBoard error : $e');
      throw Exception(e);
    }
  }

  Future<List<BoardAllType>> getBoardAll({
    required int flag,
    required int articleId,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
          '${DioApi.mainApi}/board/all',
          queryParameters: {
            'flag': flag,
            'articleId': articleId,
            'limit': limit,
          },
      );
      final result = <BoardAllType>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getBoardAll response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        board: int.parse(response.data[i]['board'].toString()),
        thumbnail: response.data[i]['thumbnail'].toString(),
        title: response.data[i]['title'].toString(),
        lossCut: response.data[i]['lossCut'].toString(),
        content: response.data[i]['content'].toString(),
        commentCount: int.parse(response.data[i]['commentCount'].toString()),
        likeCount: response.data[i]['likeCount'].toString(),
        createdAt: response.data[i]['createdAt'].toString(),
        authorId: response.data[i]['user']['userId'].toString(),
        nickname: response.data[i]['user']['nickname'].toString(),
        badge: response.data[i]['user']['badge'].toString(),
        insignia: response.data[i]['user']['insignia'].toString(),
        myRating: response.data[i]['user']['myRating'].toString());
        // result.add(BoardModel.fromJson(response.data[i]));
        result.add(records);
      }
      log('getBoardAll response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getBoardAll error : $e');
      throw Exception(e);
    }
  }

  Future<LoginType> getLogin({
    required String loginType,
    required String key,
    required String? password,
  }) async {
    try {
      var result = (token: '', userId: '');
      final response = await dio.post(
        '${DioApi.mainApi}/login',
        data: {
          'loginType': loginType,
          'key': key,
          'password': password,
        },
      );
      result = (token: response.data['token'].toString(),
        userId: response.data['userId'].toString());

      log('getLogin response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getBoardAll error : $e');
      throw Exception(e);
    }
  }

  /// popular tab에 있는 리스트 받기!
  Future<List<BoardAllType>> getPopularAll({
    required int articleId,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        '${DioApi.mainApi}/board/popular',
        queryParameters: {
          'articleId': articleId,
          'limit': limit,
        },
      );
      final result = <BoardAllType>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getPopularAll response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        board: int.parse(response.data[i]['board'].toString()),
        thumbnail: response.data[i]['thumbnail'].toString(),
        title: response.data[i]['title'].toString(),
        lossCut: response.data[i]['lossCut'].toString(),
        content: response.data[i]['content'].toString(),
        commentCount: int.parse(response.data[i]['commentCount'].toString()),
        likeCount: response.data[i]['likeCount'].toString(),
        createdAt: response.data[i]['createdAt'].toString(),
        authorId: response.data[i]['user']['userId'].toString(),
        nickname: response.data[i]['user']['nickname'].toString(),
        badge: response.data[i]['user']['badge'].toString(),
        insignia: response.data[i]['user']['insignia'].toString(),
        myRating: response.data[i]['user']['myRating'].toString());
        // result.add(BoardModel.fromJson(response.data[i]));
        result.add(records);
      }
      log('getPopularAll response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getPopularAll error : $e');
      throw Exception(e);
    }
  }
}
