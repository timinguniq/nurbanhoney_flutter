import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getProfileProvider =
    FutureProvider.autoDispose.family<ProfileType, String>((ref, token) async {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return await profileRepository.getProfile(token: token);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
