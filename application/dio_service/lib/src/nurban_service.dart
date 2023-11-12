import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getNurbanArticleProvider =
    FutureProvider.autoDispose.family<NurbanArticle, int>((ref, articleId) async {
  final nurbanRepository = ref.watch(nurbanRepositoryProvider);
  return await nurbanRepository.getNurbanArticle(articleId: articleId);
});

final createNurbanLikeProvider =
    FutureProvider.autoDispose.family<String, (String, int)>(
        (ref, record) async {
  final nurbanRepository = ref.watch(nurbanRepositoryProvider);
  return await nurbanRepository.nurbanLikeCreate(token: record.$1, articleId: record.$2);
});

final getNurbanCommentsProvider =
    FutureProvider.autoDispose.family<List<NurbanComment>, (int, int, int)>(
        (ref, records) async {
  final nurbanRepository = ref.watch(nurbanRepositoryProvider);
  return await nurbanRepository.getNurbanComments(
      articleId: records.$1,
      commentId: records.$2,
      limit: records.$3,
  );
});

final nurbanRepositoryProvider = Provider<NurbanRepository>((ref) {
  return NurbanRepository();
});
