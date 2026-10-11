import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/src/api_client.dart';
import 'package:dio_repository/src/json_fields.dart';

/// 서버 로그인 결과. 토큰은 비어 있지 않고, userId 는 내 글·댓글 판별에 쓰는 정수다.
typedef LoginType = ({String token, int userId});

/// 서버 로그인(카카오·구글 키, 레거시 이메일/비밀번호).
class DioRepository {
  DioRepository(this._client);

  final ApiClient _client;

  /// 응답은 `{result, error}` 봉투가 아니라 `{token, userId}` 다. `error` 가 오면 거절로 본다.
  Future<LoginType> getLogin({
    required String loginType,
    required String key,
    required String? password,
  }) async {
    final body = await _client.request(
      ApiMethod.post,
      '/login',
      data: {'loginType': loginType, 'key': key, 'password': password},
    );
    return ApiClient.decode(() {
      final json = jsonMap(body);
      final error = json['error'];
      if (error != null) throw ApiServerFailure(error.toString());
      final token = jsonString(json['token']);
      if (token.isEmpty) throw const FormatException('empty token');
      return (token: token, userId: jsonInt(json['userId']));
    });
  }
}
