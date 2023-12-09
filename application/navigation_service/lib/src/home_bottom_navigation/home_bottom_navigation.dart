import 'package:navigation_domain/navigation_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_bottom_navigation.g.dart';

@riverpod
class HomeBottomNavigation extends _$HomeBottomNavigation {
  @override
  HomeBottomStatus build() {
    state = HomeBottomStatus.home;
    return state;
  }

  void select(HomeBottomStatus status) {
    state = status;
  }
}