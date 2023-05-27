import 'package:authentication_domain/authentication_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_service.g.dart';

@riverpod
class AuthenticationService extends _$AuthenticationService{
  AuthenticationStatus build() {
    state = AuthenticationStatus.unauthenticated;
    return state;
  }

  void set(AuthenticationStatus status){
    state = status;
  }
}