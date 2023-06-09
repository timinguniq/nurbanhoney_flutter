import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getRankTabProvider = FutureProvider.autoDispose.family<Future<List<({int id, int userId, String badge, String nickname, Object insignia})>>, ({int offset, int limit})>((ref, records) {
  final rankRepository = ref.watch(rankRepositoryProvider);
  return rankRepository.getRankTab(offset: records.offset, limit: records.limit);
});

final rankRepositoryProvider = Provider<RankRepository>((ref) {
  return RankRepository();
});