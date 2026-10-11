import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/src/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서버 로그인. 키는 (로그인 수단, 키, 비밀번호) 다. 결과 검증(빈 토큰·숫자가 아닌 userId)은 저장소가 한다.
final getLoginProvider = FutureProvider.autoDispose.family<LoginType, (String, String, String?)>((ref, records) {
  return ref.watch(dioRepositoryProvider).getLogin(loginType: records.$1, key: records.$2, password: records.$3);
});

final dioRepositoryProvider = Provider<DioRepository>((ref) {
  return DioRepository(ref.watch(apiClientProvider));
});
