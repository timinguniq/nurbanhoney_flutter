// 2. extend [AsyncNotifier]
import 'dart:async';
import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class AsyncLogin extends AsyncNotifier<void> {
  // 3. override the [build] method to return a [FutureOr]
  @override
  FutureOr<void> build() async {
    // 4. return a value (or do nothing if the return type is void)
    //LoginType records = (token: state.value?.token ?? '',
    //userId: state.value?.userId ?? '');
    //FutureOr<LoginType> futureValue = Future.value(records);
    //return futureValue;
  }

  Future<void> signIn(String loginType, String key, String? password) async {
    // 5. read the repository using ref
    final dioRepository = ref.read(dioRepositoryProvider);

    // 6. set the loading state
    state = const AsyncLoading();
    // 7. sign in and update the state (data or error)
    state = await AsyncValue.guard(
      () async => await dioRepository.getLogin(
            loginType: loginType,
            key: key,
            password: password,
        ),
    );

    //return state.value!;
  }
}