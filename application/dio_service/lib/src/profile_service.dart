import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/src/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 내 프로필. 토큰은 [apiClientProvider] 가 붙이고, 로그인·로그아웃으로 인증 상태가 바뀌면 다시 받는다.
final getProfileProvider = FutureProvider.autoDispose<ProfileType>((ref) {
  return ref.watch(profileRepositoryProvider).getProfile();
});

final getProfileArticleProvider =
    FutureProvider.autoDispose.family<List<ProfileArticleType>, ({int offset, int limit})>((ref, page) {
  return ref.watch(profileRepositoryProvider).getMyaccountArticle(offset: page.offset, limit: page.limit);
});

final getProfileCommentProvider =
    FutureProvider.autoDispose.family<List<ProfileCommentType>, ({int offset, int limit})>((ref, page) {
  return ref.watch(profileRepositoryProvider).getMyaccountComment(offset: page.offset, limit: page.limit);
});

final getTermsProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(profileRepositoryProvider).myaccountTerms();
});

final getPrivacyProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(profileRepositoryProvider).myaccountPrivacy();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});
