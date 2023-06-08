// TODO: Put public facing types in this file.

import 'package:dio_domain/dio_domain.dart';
import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getBoardProvider = FutureProvider.autoDispose<Future<List<BoardModel>>>((ref) {
  final dioRepository = ref.watch(dioRepositoryProvider);
  return dioRepository.getBoard();
});

final dioRepositoryProvider = Provider<DioRepository>((ref) {
  return DioRepository();
});