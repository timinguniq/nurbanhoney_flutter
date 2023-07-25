import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class PasswordService extends _$PasswordService{
  @override
  String? build() {
    state = null;
    return state;
  }

  void set(String? password){
    state = password;
  }
}