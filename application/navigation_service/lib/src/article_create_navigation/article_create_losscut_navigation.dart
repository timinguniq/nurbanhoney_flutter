import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_create_losscut_navigation.g.dart';

@riverpod
class ArticleCreateLossCutNavigation extends _$ArticleCreateLossCutNavigation {
  @override
  String build() {
    state = '₩ 손실액을 입력하세요.';
    return state;
  }

  void select(String value) {
    state = value;
  }
}