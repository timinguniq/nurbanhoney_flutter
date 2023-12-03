import 'dart:developer';

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

final getNurbanAllProvider = FutureProvider.autoDispose.family<List<BoardAllType>, (int, int, int)>((ref, records) async {
  final nurbanRepository = ref.watch(nurbanRepositoryProvider);
  return await nurbanRepository.getNurbanAll(flag: records.$1, articleId: records.$2, limit: records.$3);
});

final getNurbanCommentsProvider =
    FutureProvider.autoDispose.family<List<NurbanComment>, int>(
        (ref, articleId) async {
  final nurbanRepository = ref.watch(nurbanRepositoryProvider);
  final commentIdRecords = ref.watch(nurbanCommentIdProvider);
  log("commentId : ${commentIdRecords.$1}");
  return await nurbanRepository.getNurbanComments(
    articleId: articleId,
    commentId: commentIdRecords.$1,
    limit: 10,
  );
});

final nurbanRepositoryProvider = Provider<NurbanRepository>((ref) {
  return NurbanRepository();
});
