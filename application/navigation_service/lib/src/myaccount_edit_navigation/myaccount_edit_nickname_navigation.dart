import 'package:riverpod_annotation/riverpod_annotation.dart';

//part 'article_create_content_navigation.g.dart';

// TODO: 수정해야 된다.
@riverpod
class MyaccountEditNicknameNavigation extends _$ArticleCreateContentNavigation {

  @override
  String build() {
    state = '내용을 입력하세요.';
    return state;
  }

  void select(String value) {
    state = value;
  }
}