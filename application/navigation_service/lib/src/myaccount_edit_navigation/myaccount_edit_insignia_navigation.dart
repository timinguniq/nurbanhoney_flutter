import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'myaccount_edit_insignia_navigation.g.dart';

@riverpod
class MyaccountEditInsigniaNavigation extends _$MyaccountEditInsigniaNavigation {
  @override
  List<String> build() {
    state = <String>[];
    return state;
  }

  void select(String value) {
    state.add(value);
  }
}