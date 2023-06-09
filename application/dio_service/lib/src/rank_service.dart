import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getRankTabProvider = FutureProvider.autoDispose.family<List<({int id, int userId, String badge, String nickname, Object insignia})>, ({int offset, int limit})>((ref, records) async {
  final rankRepository = ref.watch(rankRepositoryProvider);
  return await rankRepository.getRankTab(offset: records.offset, limit: records.limit);
});

final rankRepositoryProvider = Provider<RankRepository>((ref) {
  return RankRepository();
});