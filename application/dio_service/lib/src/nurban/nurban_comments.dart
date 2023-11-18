import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nurban_comments.g.dart';

@riverpod
class NurbanComments extends _$NurbanComments{
  @override
  List<NurbanComment>? build() {
    state = null;
    return state;
  }

  Future<void> set({
    required int articleId,
    required int commentId,
    required int limit,
  }) async {
    final nurbanRepository = ref.read(nurbanRepositoryProvider);
    final result = await nurbanRepository.getNurbanComments(
        articleId: articleId,
        commentId: commentId,
        limit: limit,
    );
    state = result;
  }
}