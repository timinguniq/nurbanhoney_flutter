import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'myaccount_edit_insignia_navigation.g.dart';

@riverpod
class MyaccountEditInsigniaNavigation extends _$MyaccountEditInsigniaNavigation {
  @override
  String build() {
    state = '';
    return state;
  }

  void select(String value) {
    state = value;
  }
}