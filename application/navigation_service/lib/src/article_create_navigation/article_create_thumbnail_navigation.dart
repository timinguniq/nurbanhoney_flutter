import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_create_thumbnail_navigation.g.dart';

@riverpod
class ArticleCreateThumbnailNavigation extends _$ArticleCreateThumbnailNavigation {
  @override
  int build() {
    state = -1;
    return state;
  }

  void select(int value) {
    state = value;
  }
}