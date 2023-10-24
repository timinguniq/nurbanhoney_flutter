import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_create_uuid_navigation.g.dart';

@riverpod
class ArticleCreateUuidNavigation extends _$ArticleCreateUuidNavigation{
  @override
  String build() {
    state = '';
    return state;
  }

  void select(String value) {
    state = value;
  }
}