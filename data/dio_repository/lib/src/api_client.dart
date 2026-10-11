import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_domain/dio_domain.dart';

/// 세션 토큰을 읽는다. 로그인하지 않았으면 null.
typedef TokenReader = Future<String?> Function();

/// HTTP 메서드. Dio 에는 대문자 이름으로 넘긴다.
enum ApiMethod { get, post, put, delete }

/// 모든 저장소가 거치는 HTTP 클라이언트 하나(ADR-0001).
///
/// - 토큰이 있을 때만 `Authorization: Bearer` 를 붙인다. 없으면 헤더 자체를 보내지 않는다.
/// - 타임아웃은 여기서 정한다. 업로드처럼 오래 걸리는 요청만 [request] 의 `receiveTimeout` 으로 늘린다.
/// - 전송 오류·HTTP 오류·서버 `error` 봉투·응답 모양 불일치를 모두 [ApiFailure] 로 바꿔 던진다.
///   저장소 밖으로는 [ApiFailure] 외의 예외가 나가지 않는다.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenReader readToken,
    HttpClientAdapter? adapter,
    bool logging = false,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
        )) {
    if (adapter != null) _dio.httpClientAdapter = adapter;
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final String? token;
      try {
        token = await readToken();
      } catch (e, stackTrace) {
        handler.reject(DioException(requestOptions: options, error: e, stackTrace: stackTrace));
        return;
      }
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }));
    if (logging) {
      // 요청 헤더는 찍지 않는다(Authorization 노출 방지).
      _dio.interceptors.add(LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        responseBody: true,
        logPrint: (line) => log('$line', name: 'api'),
      ));
    }
  }

  static const connectTimeout = Duration(seconds: 5);
  static const receiveTimeout = Duration(seconds: 10);

  /// 이미지 업로드처럼 본문이 큰 요청의 수신 제한.
  static const uploadReceiveTimeout = Duration(seconds: 30);

  final Dio _dio;

  /// GET 요청. 응답 JSON(Map 또는 List)을 그대로 돌려준다.
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      request(ApiMethod.get, path, query: query);

  /// 임의 메서드 요청. 응답 JSON 을 그대로 돌려준다.
  Future<dynamic> request(
    ApiMethod method,
    String path, {
    Map<String, dynamic>? query,
    Object? data,
    Duration? receiveTimeout,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        queryParameters: query,
        data: data,
        options: Options(method: method.name.toUpperCase(), receiveTimeout: receiveTimeout),
      );
      return response.data;
    } on DioException catch (e) {
      throw _failureOf(e);
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiUnknown(e);
    }
  }

  /// `{result, error}` 봉투를 돌려주는 명령. `error` 가 있으면 [ApiServerFailure], 없으면 `result` 를 돌려준다.
  Future<Object?> command(
    ApiMethod method,
    String path, {
    Map<String, dynamic>? query,
    Object? data,
    Duration? receiveTimeout,
  }) async {
    final body = await request(method, path, query: query, data: data, receiveTimeout: receiveTimeout);
    if (body is! Map) {
      throw ApiFormatFailure('envelope expected, got ${body.runtimeType}');
    }
    final error = body['error'];
    if (error != null) throw ApiServerFailure(error.toString());
    return body['result'];
  }

  /// `result` 가 기대한 성공 리터럴인지까지 확인하는 명령. 다르면 [ApiFormatFailure].
  Future<void> expectResult(
    ApiMethod method,
    String path, {
    Object? data,
    required String result,
  }) async {
    final actual = await command(method, path, data: data);
    if (actual != result) {
      throw ApiFormatFailure("expected result '$result', got '$actual'");
    }
  }

  /// 응답 JSON 을 레코드로 바꾸는 [parse] 를 감싼다. 타입 불일치·형식 오류는 [ApiFormatFailure] 가 된다.
  static T decode<T>(T Function() parse) {
    try {
      return parse();
    } on ApiFailure {
      rethrow;
    } catch (e) {
      throw ApiFormatFailure('$e');
    }
  }

  static ApiFailure _failureOf(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiTimeout();
      case DioExceptionType.connectionError:
        return const ApiOffline();
      case DioExceptionType.badResponse:
        final response = e.response;
        final data = response?.data;
        return ApiHttpFailure(
          status: response?.statusCode ?? 0,
          serverError: data is Map ? data['error']?.toString() : null,
        );
      // badCertificate·cancel·unknown, 그리고 Dio 버전에 따라 추가되는 종류(transformTimeout 등).
      default:
        final cause = e.error;
        if (cause is SocketException) return const ApiOffline();
        if (cause is ApiFailure) return cause;
        return ApiUnknown(cause ?? e);
    }
  }
}
