import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

typedef ProfileType = ({
  int id,
  String loginType,
  String badge,
  String nickname,
  String description,
  int point,
  String insigniaShow,
  String insigniaOwn,
  int myArticleCount,
  int myCommentCount
});

class ProfileRepository {
  /// constructor
  ProfileRepository._privateConstructor();

  static final ProfileRepository _instance =
      ProfileRepository._privateConstructor();

  factory ProfileRepository() {
    return _instance;
  }

  final dio = Dio();

  // 참고해서 getProfile 만들기
  Future<ProfileType> getProfile({
    required String token,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/profile',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.get('/');

      final result = (
        id: int.parse(response.data['id'].toString()),
        loginType: response.data['loginType'].toString(),
        badge: response.data['badge'].toString(),
        nickname: response.data['nickname'].toString(),
        description: response.data['description'].toString(),
        point: int.parse(response.data['point'].toString()),
        insigniaShow: response.data['insigniaShow'].toString(),
        insigniaOwn: response.data['insigniaOwn'].toString(),
        myArticleCount: int.parse(response.data['myArticleCount'].toString()),
        myCommentCount: int.parse(response.data['myCommentCount'].toString())
      );
      log('getProfile result: ${result.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getProfile error : $e');
      throw Exception(e);
    }
  }
}
