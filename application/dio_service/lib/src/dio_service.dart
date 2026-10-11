import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getLoginProvider = FutureProvider.autoDispose.family<LoginType, (String, String, String?)>((ref, records) {
  return ref.watch(dioRepositoryProvider).getLogin(loginType: records.$1, key: records.$2, password: records.$3);
});

final dioRepositoryProvider = Provider<DioRepository>((ref) {
  return DioRepository();
});
