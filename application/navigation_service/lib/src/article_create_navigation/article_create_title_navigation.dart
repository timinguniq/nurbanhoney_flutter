import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_create_title_navigation.g.dart';

@riverpod
class ArticleCreateTitleNavigation extends _$ArticleCreateTitleNavigation {
  @override
  String build() {
    state = '제목을 입력하세요.';
    return state;
  }

  void select(String value) {
    state = value;
  }
}