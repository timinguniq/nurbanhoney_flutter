import 'package:authentication_domain/authentication_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_service.g.dart';

@riverpod
class AuthenticationService extends _$AuthenticationService{
  final _status = AuthenticationStatus.unknown;

  @override
  AuthenticationStatus build() {
    return _status;
  }
}