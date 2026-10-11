import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/src/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final freeRepositoryProvider = Provider<FreeRepository>((ref) {
  return FreeRepository(ref.watch(apiClientProvider));
});
