import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'myaccount_edit_insignia_navigation.g.dart';

@riverpod
class MyaccountEditInsigniaNavigation extends AutoDisposeNotifier<String> {
  @override
  String build() {
    state = '';
    return state;
  }

  void select(String value) {
    state = value;
  }
}