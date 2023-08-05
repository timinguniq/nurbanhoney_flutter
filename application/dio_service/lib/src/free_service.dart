import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFreeArticleProvider =
    FutureProvider.autoDispose.family<FreeArticle, int>((ref, articleId) async {
  final freeRepository = ref.watch(freeRepositoryProvider);
  return await freeRepository.getFreeArticle(articleId: articleId);
});

final freeRepositoryProvider = Provider<FreeRepository>((ref) {
  return FreeRepository();
});
