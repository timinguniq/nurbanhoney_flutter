import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

typedef NurbanArticle = ({
  int id, String uuid, String thumbnail,
  String title, String lossCut, String content,
  int count, int commentCount,
  int likeCount, int dislikeCount,
  String updatedAt,
  int userId, String badge,
  String nickname, String insignia,
  String myRating,
});

class NurbanRepository {
  /// constructor
  NurbanRepository._privateConstructor();
  static final NurbanRepository _instance = NurbanRepository._privateConstructor();

  factory NurbanRepository(){
    return _instance;
  }

  final dio = Dio();

  /// 너반꿀 아티클 상세
  Future<NurbanArticle> getNurbanArticle({
    required int articleId,
  }) async {
    try {
      final response = await dio.get(
        '${DioApi.mainApi}/board/nurban/article',
        queryParameters: {
          'id': articleId,
        },
      );

      log('getNurbanArticle response: ${response.data}');
      final records =
        (id: int.parse(response.data['id'].toString()),
        uuid: response.data['uuid'].toString(),
        thumbnail: response.data['thumbnail'].toString(),
        title: response.data['title'].toString(),
        lossCut: response.data['lossCut'].toString(),
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

      log('getNurbanArticle response: ${response.data.toString()}');

      final futureValue = Future.value(records);
      return futureValue;
    } catch (e) {
      log('getNurbanArticle error : $e');
      throw Exception(e);
    }
  }

  /// 아티클 좋아요 생성
  Future<String> nurbanLikeCreate({
    required String token,
    required int articleId,
  }) async {
    try {

      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/nurban/article/like',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.post('/',
        data: {'articleId': articleId},
      );

      log('nurbanLikeCreate response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'].toString();

      final futureValue = error != ''
          ? Future.value(error)
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanLikeCreate error : $e');
      throw Exception(e);
    }
  }
}