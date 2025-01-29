
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';

typedef FreeArticle = ({
  int id, String uuid,
  String title, String content,
  int count, int commentCount,
  int likeCount, int dislikeCount,
  String updatedAt,
  int userId, String badge,
  String nickname, String insignia,
  String myRating,
});

class FreeRepository {
  /// constructor
  FreeRepository._privateConstructor();
  static final FreeRepository _instance = FreeRepository._privateConstructor();

  factory FreeRepository(){
    return _instance;
  }

  final dio = Dio();

  /// 자유게시판 아티클 상세
  Future<FreeArticle> getFreeArticle({
    required String token,
    required int articleId,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/free/article',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.get('/',
        queryParameters: {
          'id': articleId,
        },
      );
      /*
      final response = await dio.get(
        '${DioApi.mainApi}/board/free/article',
        queryParameters: {
          'id': articleId,
        },
      );
*/
      log('getFreeArticle response: ${response.data}');
      final records =
      (id: int.parse(response.data['id'].toString()),
      uuid: response.data['uuid'].toString(),
      title: response.data['title'].toString(),
      content: response.data['content'].toString(),
      count: int.parse(response.data['count'].toString()),
      commentCount: int.parse(response.data['commentCount'].toString()),
      likeCount: int.parse(response.data['likeCount'].toString()),
      dislikeCount: int.parse(response.data['dislikeCount'].toString()),
      updatedAt: response.data['updatedAt'].toString(),
      userId: int.parse(response.data['userId'].toString()),
      badge: response.data['badge'].toString(),
      nickname: response.data['nickname'].toString(),
      insignia: response.data['insignia'].toString(),
      myRating: response.data['myRating'].toString());

      log('getFreeArticle response: ${response.data.toString()}');

      final futureValue = Future.value(records);
      return futureValue;
    } catch (e) {
      log('getFreeArticle error : $e');
      throw Exception(e);
    }
  }

  /// 자유게시판 리스트 조회
  Future<List<BoardAllType>> getFreeAll({
    required int flag,
    required int articleId,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        '${DioApi.mainApi}/board/free',
        queryParameters: {
          'flag': flag,
          'articleId': articleId,
          'limit': limit,
        },
      );
      final result = <BoardAllType>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getFreeAll response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        board: 2,
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
      log('getFreeAll response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getFreeAll error : $e');
      throw Exception(e);
    }
  }

  /// 아티클 생성
  Future<String> freeArticleCreate({
    required String token,
    required String title,
    required String uuid,
    required String content,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/free/article',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.post('/',
        data: {
          'title': title,
          'uuid': uuid,
          'content': content,
        },
      );

      log('nurbanFreeCreate response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanFreeCreate error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanFreeCreate error : $e');
      throw Exception(e);
    }
  }
}
