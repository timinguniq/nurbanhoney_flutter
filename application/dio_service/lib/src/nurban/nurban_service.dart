import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/src/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 글 상세. 토큰은 [apiClientProvider] 가 붙이므로 로그인했으면 내 반응(myReaction)도 온다.
final getNurbanArticleProvider = FutureProvider.autoDispose.family<NurbanArticle, int>((ref, articleId) {
  return ref.watch(nurbanRepositoryProvider).getNurbanArticle(articleId: articleId);
});

/// 댓글 목록. 기존처럼 처음부터 10개만 받는다(커서 -1).
final getNurbanCommentsProvider = FutureProvider.autoDispose.family<List<NurbanComment>, int>((ref, articleId) {
  return ref.watch(nurbanRepositoryProvider).getNurbanComments(articleId: articleId, commentId: -1, limit: 10);
});

final nurbanRepositoryProvider = Provider<NurbanRepository>((ref) {
  return NurbanRepository(ref.watch(apiClientProvider));
});
