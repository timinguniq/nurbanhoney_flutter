import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFreeArticleProvider =
    FutureProvider.autoDispose.family<FreeArticle, (String, int)>((ref, record) async {
  final freeRepository = ref.watch(freeRepositoryProvider);
  return await freeRepository.getFreeArticle(token: record.$1, articleId: record.$2);
});

final getFreeAllProvider = FutureProvider.autoDispose.family<List<BoardAllType>, (int, int, int, String?)>((ref, records) async {
  final freeRepository = ref.watch(freeRepositoryProvider);
  return await freeRepository.getFreeAll(flag: records.$1, articleId: records.$2, limit: records.$3, token: records.$4);
});

final freeRepositoryProvider = Provider<FreeRepository>((ref) {
  return FreeRepository();
});
