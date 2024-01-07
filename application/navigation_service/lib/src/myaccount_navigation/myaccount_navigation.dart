import 'package:navigation_domain/navigation_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'myaccount_navigation.g.dart';

@riverpod
class MyaccountNavigation extends _$MyaccountNavigation {
  @override
  MyaccountTabStatus build() {
    state = MyaccountTabStatus.article;
    return state;
  }

  void select(MyaccountTabStatus status) {
    state = status;
  }
}