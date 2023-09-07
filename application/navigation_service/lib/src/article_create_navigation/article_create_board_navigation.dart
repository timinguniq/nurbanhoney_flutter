import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_create_board_navigation.g.dart';

@riverpod
class ArticleCreateBoardNavigation extends _$ArticleCreateBoardNavigation {
  @override
  String build() {
    state = '등록위치 선택';
    return state;
  }

  void select(String value) {
    state = value;
  }
}