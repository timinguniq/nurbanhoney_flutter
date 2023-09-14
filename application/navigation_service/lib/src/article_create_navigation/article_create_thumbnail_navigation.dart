import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_create_thumbnail_navigation.g.dart';

@riverpod
class ArticleCreateThumbnailNavigation extends _$ArticleCreateThumbnailNavigation {
  @override
  String build() {
    state = '';
    return state;
  }

  void select(String value) {
    state = value;
  }
}