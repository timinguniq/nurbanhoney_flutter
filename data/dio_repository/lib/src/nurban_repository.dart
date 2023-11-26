import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:mime/mime.dart';

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

typedef NurbanComment = ({
  int id, String content,
  int userId, String badge,
  String nickname, String insignia
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
      final error = response.data['error'];

      log('nurbanLikeCreate error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanLikeCreate error : $e');
      throw Exception(e);
    }
  }

  /// 아티클 좋아요 삭제
  Future<String> nurbanLikeDelete({
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
      final response = await authDio.delete('/',
        data: {'articleId': articleId},
      );

      log('nurbanLikeDelete response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanLikeDelete error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanLikeDelete error : $e');
      throw Exception(e);
    }
  }

  /// 아티클 싫어요 생성
  Future<String> nurbanDislikeCreate({
    required String token,
    required int articleId,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/nurban/article/dislike',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.post('/',
        data: {'articleId': articleId},
      );

      log('nurbanDislikeCreate response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanDislikeCreate error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanDislikeCreate error : $e');
      throw Exception(e);
    }
  }

  /// 아티클 싫어요 삭제
  Future<String> nurbanDislikeDelete({
    required String token,
    required int articleId,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/nurban/article/dislike',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.delete('/',
        data: {'articleId': articleId},
      );

      log('nurbanDislikeDelete response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanDislikeDelete error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanDislikeDelete error : $e');
      throw Exception(e);
    }
  }

  /// 너반꿀 이미지 업로드 생성
  Future<String> nurbanImageUpload({
    required String uuid,
    required String token,
    required File image,
  }) async {
    try {
      log('nurbanImage token: $token');

      Options options = Options(
        contentType: lookupMimeType(image.path),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
          'Accept': "*/*",
          'Content-Length': image.length,
          'Connection': 'keep-alive',
          'User-Agent': 'ClinicPlush'
        },
      );

      final formData = FormData.fromMap({
        'uuid': uuid,
        'image': await MultipartFile.fromFile(image.path),
      });

      log('nurbanImage uuid: $uuid');
      log('nurbanImage filename: ${image.path.split('/').last}');

      //final authDio = Dio(baseOptions);
      final response = await Dio().post('${DioApi.mainApi}/board/nurban/article/upload/image',
        data: formData,
        options: options,
      );


      log('nurbanImageUpload response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanImageUpload error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanImageUpload e : $e');
      throw Exception(e);
    }
  }

  /// 너반꿀 이미지 삭제
  Future<String> nurbanImageDelete({
    required String uuid,
    required String token,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/nurban/article/upload/image',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.delete('/',
        data: {'uuid': uuid},
      );

      log('nurbanImageDelete response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanImageDelete error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanImageDelete error : $e');
      throw Exception(e);
    }
  }

  /// 아티클 생성
  Future<String> nurbanArticleCreate({
    required String token,
    required String title,
    required String uuid,
    required int lossCut,
    required String thumbnail,
    required String content,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/nurban/article',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.post('/',
        data: {
          'title': title,
          'uuid': uuid,
          'lossCut': lossCut,
          'thumbnail': thumbnail,
          'content': content,
        },
      );

      log('nurbanArticleCreate response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanArticleCreate error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanArticleCreate error : $e');
      throw Exception(e);
    }
  }

  /// 댓글 리스트 조회
  Future<List<NurbanComment>> getNurbanComments({
    required int articleId,
    required int commentId,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
          '${DioApi.mainApi}/board/nurban/article/comment',
          queryParameters: {
            'articleId': articleId,
            'commentId': commentId,
            'limit': limit,
          },
      );
      final result = <NurbanComment>[];
      for(int i = 0; i < response.data.length ; i++) {
        log('getNurbanComments response: ${response.data[i]}');
        final records =
        (id: int.parse(response.data[i]['id'].toString()),
        content: response.data[i]['content'].toString(),
        userId: int.parse(response.data[i]['user']['userId'].toString()),
        badge: response.data[i]['user']['badge'].toString(),
        nickname: response.data[i]['user']['nickname'].toString(),
        insignia: response.data[i]['user']['insignia'].toString());
        result.add(records);
      }
      log('getNurbanComments response: ${response.data.toString()}');

      final futureValue = Future.value(result);
      return futureValue;
    } catch (e) {
      log('getNurbanComments error : $e');
      throw Exception(e);
    }
  }

  /// 댓글 작성
  Future<String> nurbanCommentCreate({
    required String token,
    required int articleId,
    required String content,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/nurban/article/comment',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.post('/',
        data: {
          'articleId': articleId,
          'content': content,
        },
      );

      log('nurbanCommentCreate response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanCommentCreate error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanCommentCreate error : $e');
      throw Exception(e);
    }
  }

  /// 댓글 삭제
  Future<String> nurbanCommentDelete({
    required String token,
    required int commentId,
    required int articleId,
  }) async {
    try {
      final baseOptions = BaseOptions(
        baseUrl: '${DioApi.mainApi}/board/nurban/article/comment',
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      );

      final authDio = Dio(baseOptions);
      final response = await authDio.delete('/',
        data: {
          'id': commentId,
          'articleId': articleId,
        },
      );

      log('nurbanCommentDelete response: ${response.data}');

      final result = response.data['result'].toString();
      final error = response.data['error'];

      log('nurbanCommentDelete error: $error');

      final futureValue = error != null
          ? Future.value(error.toString())
          : Future.value(result);

      return futureValue;
    } catch (e) {
      log('nurbanCommentDelete error : $e');
      throw Exception(e);
    }
  }

}