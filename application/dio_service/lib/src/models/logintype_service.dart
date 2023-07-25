import 'package:dio_domain/dio_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logintype_service.g.dart';

@riverpod
class LoginTypeService extends _$LoginTypeService{
  @override
  LoginTypeStatus build() {
    state = LoginTypeStatus.init;
    return state;
  }

  void set(LoginTypeStatus status){
    state = status;
  }
}