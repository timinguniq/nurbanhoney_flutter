import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
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
  // TODO : 초기값을 commentId를 Provider로 바꾸기.
  var nurbanComments = ref.watch(nurbanCommentsProvider);
  nurbanComments = await nurbanRepository.getNurbanComments(
    articleId: records.$1,
    commentId: records.$2,
    limit: records.$3,
  );
  return nurbanComments ?? [];
});

final nurbanRepositoryProvider = Provider<NurbanRepository>((ref) {
  return NurbanRepository();
});
