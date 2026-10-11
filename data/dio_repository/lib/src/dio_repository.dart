import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

typedef LoginType = ({String token, String userId});

/// 서버 로그인. 아직 [ApiClient] 로 옮기지 않았다(ADR-0001, 다음 커밋에서 옮긴다).
class DioRepository {
  /// constructor
  DioRepository._privateConstructor();

  static final DioRepository _instance = DioRepository._privateConstructor();

  factory DioRepository() {
    return _instance;
  }

  final dio = Dio();

  Future<LoginType> getLogin({
    required String loginType,
    required String key,
    required String? password,
  }) async {
    try {
      var result = (token: '', userId: '');
      final response = await dio.post(
        '${DioMainApi.mainApi}/login',
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
      return await futureValue;
    } catch (e) {
      log('getBoardAll error : $e');
      throw Exception(e);
    }
  }
}
