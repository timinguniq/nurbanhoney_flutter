import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'myaccount_edit_nickname_navigation.g.dart';

@riverpod
class MyaccountEditNicknameNavigation extends _$MyaccountEditNicknameNavigation {
  @override
  String build() {
    state = '';
    return state;
  }

  void select(String value) {
    state = value;
  }
}