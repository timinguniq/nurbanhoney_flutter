import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nurban_comment_id.g.dart';

@riverpod
class NurbanCommentId extends _$NurbanCommentId{
  @override
  int build() {
    state = -1;
    return state;
  }

  void set({
    required int commentId,
  }) {
    state = commentId;
  }
}