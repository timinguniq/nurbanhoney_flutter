import 'package:navigation_domain/navigation_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_appbar_navigation.g.dart';

@riverpod
class HomeAppbarNavigation extends _$HomeAppbarNavigation {
  @override
  HomeAppbarStatus build() {
    return state;
  }

  void select(HomeAppbarStatus status) {
    state = status;
  }
}