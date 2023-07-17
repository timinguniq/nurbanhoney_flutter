// 2. extend [AsyncNotifier]
import 'dart:async';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginController extends AsyncNotifier<LoginType> {
  // 3. override the [build] method to return a [FutureOr]
  @override
  FutureOr<LoginType> build() {
    // 4. return a value (or do nothing if the return type is void)
    return FutureOr(
      // LoginType constructor
      <LoginType>
        (token: state.value?.token.toString() ?? '',
        userId: state.value?.userId.toString() ?? '')
    );
  }

  Future<void> signIn(String loginType, String key, String? password) async {
    // 5. read the repository using ref
    final dioRepository = ref.read(dioRepositoryProvider);
    // 6. set the loading state
    state = const AsyncLoading();
    // 7. sign in and update the state (data or error)
    state = await AsyncValue.guard(
      () => dioRepository.getLogin(
            loginType: loginType,
            key: key,
            password: password,
        ),
    );
  }
}