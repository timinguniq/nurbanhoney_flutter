import 'package:authentication_service/authentication_service.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 모든 저장소가 공유하는 HTTP 클라이언트(ADR-0001).
///
/// 인증 상태를 `watch` 하므로 로그인·로그아웃·탈퇴로 상태가 바뀌면 클라이언트가 다시 만들어지고, 이 provider 에
/// 기댄 저장소 provider 와 `FutureProvider` 가 전부 다시 구성된다. 토큰은 요청 시점에 저장소에서 읽으므로
/// 저장소 쓰기가 끝난 뒤 상태를 바꾸는 지금 순서(로그인·로그아웃 화면)와 맞물린다.
final apiClientProvider = Provider<ApiClient>((ref) {
  ref.watch(authenticationServiceProvider);
  return ApiClient(
    baseUrl: DioMainApi.mainApi,
    readToken: () async {
      final storage = await ref.read(preferenceStorageProvider.future);
      return storage.hasToken() ? storage.getToken() : null;
    },
    logging: kDebugMode,
  );
});
