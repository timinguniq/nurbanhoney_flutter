import 'package:authentication_domain/authentication_domain.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_service.g.dart';

@riverpod
class AuthenticationService extends _$AuthenticationService{
  var _status = AuthenticationStatus.unknown;

  @override
  AuthenticationStatus build() {
    return _status;
  }

  void setAuth(){
    _status = AuthenticationStatus.authenticated;
  }

  void setUnAuth(){
    final preferenceStorage = ref.read(preferenceStorageProvider);
    preferenceStorage.value?.setEmptyToken();
    _status = AuthenticationStatus.unauthenticated;
  }
}