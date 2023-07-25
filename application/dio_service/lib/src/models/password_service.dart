import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'password_service.g.dart';

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