import 'package:dio_repository/dio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nurbanRepositoryProvider = Provider<NurbanRepository>((ref) {
  return NurbanRepository();
});