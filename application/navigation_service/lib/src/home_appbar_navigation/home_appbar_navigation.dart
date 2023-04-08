import 'package:navigation_domain/navigation_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_appbar_navigation.g.dart';

@riverpod
class HomeAppbarNavigation extends _$HomeAppbarNavigation {
  final _status = HomeAppbarStatus.whole;

  @override
  HomeAppbarStatus build() {
    return _status;
  }
}