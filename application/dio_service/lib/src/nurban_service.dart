import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getNurbanArticleProvider =
    FutureProvider.autoDispose.family<NurbanArticle, int>((ref, articleId) async {
  final nurbanRepository = ref.watch(nurbanRepositoryProvider);
  return await nurbanRepository.getNurbanArticle(articleId: articleId);
});

final nurbanRepositoryProvider = Provider<NurbanRepository>((ref) {
  return NurbanRepository();
});
