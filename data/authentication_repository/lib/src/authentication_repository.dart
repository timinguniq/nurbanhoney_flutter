import 'dart:async';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:preference_storage/preference_storage.dart';

/// {@template authentication_repository}
/// Repository manage login status.
/// {@endtemplate}
class AuthenticationRepository {
  /// constructor
  AuthenticationRepository({
    required PreferenceStorage preferenceStorage,
  }) : _preferenceStorage = preferenceStorage;

  final _controller = StreamController<AuthenticationStatus>();
  final PreferenceStorage _preferenceStorage;

  /// make stream status
  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unknown;
    yield* _controller.stream;
  }

  /// change status
  void changeStates(AuthenticationStatus status) {
    _controller.add(status);
  }

  /// set authentication
  void setAuthenticated() {
    _controller.add(AuthenticationStatus.authenticated);
  }

  /// set un authentication
  Future<void> setUnauthenticated() async {
    await _preferenceStorage.setEmptyToken();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  /// dispose
  void dispose() => _controller.close();
}
