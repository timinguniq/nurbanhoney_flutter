
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

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
}
