import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getProfileProvider =
    FutureProvider.autoDispose.family<ProfileType, String>((ref, token) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return await profileRepository.getProfile(token: token);
});

final getProfileArticleProvider =
    FutureProvider.autoDispose.family<List<ProfileArticleType>, (String, int, int)>((ref, records) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return await profileRepository.getMyaccountArticle(
      token: records.$1,
      offset: records.$2,
      limit: records.$3,
  );
});

final getProfileCommentProvider =
    FutureProvider.autoDispose.family<List<ProfileCommentType>, (String, int, int)>((ref, records) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return await profileRepository.getMyaccountComment(
      token: records.$1,
      offset: records.$2,
      limit: records.$3,
  );
});

final getTermsProvider = FutureProvider.autoDispose<String>((ref) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return await profileRepository.myaccountTerms();
});

final getPrivacyProvider = FutureProvider.autoDispose<String>((ref) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return await profileRepository.myaccountPrivacy();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
