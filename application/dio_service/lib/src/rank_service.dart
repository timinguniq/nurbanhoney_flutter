import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/src/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getRankTabProvider =
    FutureProvider.autoDispose.family<List<RankType>, ({int offset, int limit})>((ref, request) {
  return ref.watch(rankRepositoryProvider).getRankTab(offset: request.offset, limit: request.limit);
});

final getRankProvider = FutureProvider.autoDispose<List<RankType>>((ref) {
  return ref.watch(rankRepositoryProvider).getRanks();
});

final rankRepositoryProvider = Provider<RankRepository>((ref) {
  return RankRepository(ref.watch(apiClientProvider));
});
