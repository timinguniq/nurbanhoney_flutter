import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final freeRepositoryProvider = Provider<FreeRepository>((ref) {
  return FreeRepository();
});