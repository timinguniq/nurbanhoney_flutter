// TODO: Put public facing types in this file.

import 'dart:developer';

import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getBoardProvider = FutureProvider.autoDispose<Future<List<({int id, int type, String name, String address})>>>((ref) {
  final dioRepository = ref.watch(dioRepositoryProvider);
  return dioRepository.getBoard();
});

final getBoardAllProvider = FutureProvider.autoDispose.family<List<BoardAllType>, (int, int, int)>((ref, records) async {
  final dioRepository = ref.watch(dioRepositoryProvider);
  return await dioRepository.getBoardAll(flag: records.$1, articleId: records.$2, limit: records.$3);
});

final getLoginProvider = FutureProvider.autoDispose.family<LoginType, (String, String, String?)>((ref, records) async {
  final dioRepository = ref.watch(dioRepositoryProvider);
  log('getLoginProvider: $records');
  return await dioRepository.getLogin(loginType: records.$1, key: records.$2, password: records.$3);
});

final getLoginTestProvider = AsyncNotifierProvider
    .autoDispose.family<AsyncLogin, LoginType, (String, String, String?)>(() => AsyncLogin());

final dioRepositoryProvider = Provider<DioRepository>((ref) {
  return DioRepository();
});