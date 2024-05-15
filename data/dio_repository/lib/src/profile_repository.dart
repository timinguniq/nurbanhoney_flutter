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

typedef ProfileArticleType = ({
  int id,
  int board,
  String thumbnail,
  String title,
  int count,
  int commentCount,
  String createdAt,
});

typedef ProfileCommentType = ({
  int id,
  int board,
  String title,
  String content,
  String createdAt,
  int articleId,
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

  // getProfile
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

      log('getProfile response: ${response.data}');

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

  // getProfileEdit
  Future<String> profileEdit({
    required String token,
    required String nickname,
    required String description,
    required String insignia,
  }) async {
    try {
      log('profileEdit insignia: $insignia');

      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/profile/edit',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.patch('/',
          data: {
            'nickname': nickname,
            'description': description,
            'insignia': insignia,
          },
      );

      log('profileEdit response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('profileEdit error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('profileEdit error : $e');
      throw Exception(e);
    }
  }


  Future<List<ProfileArticleType>> getMyaccountArticle({
    required String token,
    required int offset,
    required int limit,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/profile/myarticle',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.get(
          '/',
          queryParameters: {
            'offset': offset,
            'limit': limit,
          },
      );

      final result = <ProfileArticleType>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getBoardAll response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        board: int.parse(response.data[i]['board'].toString()),
        thumbnail: response.data[i]['thumbnail'].toString(),
        title: response.data[i]['title'].toString(),
        count: int.parse(response.data[i]['count'].toString()),
        commentCount: int.parse(response.data[i]['commentCount'].toString()),
        createdAt: response.data[i]['createdAt'].toString());
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

  Future<List<ProfileCommentType>> getMyaccountComment({
    required String token,
    required int offset,
    required int limit,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/profile/mycomment',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.get(
        '/',
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );

      final result = <ProfileCommentType>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('Mycomment response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        board: int.parse(response.data[i]['board'].toString()),
        title: response.data[i]['location']['title'].toString(),
        content: response.data[i]['content'].toString(),
        createdAt: response.data[i]['createdAt'].toString(),
        articleId: int.parse(response.data[i]['location']['articleId'].toString()));
        // result.add(BoardModel.fromJson(response.data[i]));
        result.add(records);
      }
      log('Mycomment response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('Mycomment error : $e');
      throw Exception(e);
    }
  }

  Future<String> myaccountWithdrawal({
    required String token,
    required int userId,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/profile/withdrawal',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.delete(
        '/',
        data: {
          'id': userId,
        },
      );

      log('withdrawal response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('withdrawal error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('withdrawal error : $e');
      throw Exception(e);
    }
  }

  Future<String> myaccountTerms() async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/profile/withdrawal',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.get(
        '/',
      );

      log('withdrawal response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('withdrawal error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('withdrawal error : $e');
      throw Exception(e);
    }
  }


}
