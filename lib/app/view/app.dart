import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class App extends StatelessWidget {
  const App({
    required String deviceId,
    super.key,
  }) : _deviceId = deviceId;

  final String _deviceId;

  @override
  Widget build(BuildContext context) {
    return AppView(
      deviceId: _deviceId,
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({
    required String deviceId,
    super.key,
  }) : _deviceId = deviceId;

  final String _deviceId;

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  Future<void> setDeviceId(WidgetRef ref, String deviceId) async {
    final prefStorageProvider = ref.watch(preferenceStorageProvider);
    final prefStorage = prefStorageProvider.asData?.value;

    await prefStorage?.setDeviceId(deviceId);
  }

  Future<void> setAuth(WidgetRef ref) async {
    final preferenceStorage = ref.watch(preferenceStorageProvider);
    final storage = preferenceStorage.asData?.value;
    final token = storage?.getToken() ?? '__empty__';

    if (token == '__empty__') {
      ref
          .watch(authenticationServiceProvider.notifier)
          .set(AuthenticationStatus.unauthenticated);
    } else {
      ref
          .watch(authenticationServiceProvider.notifier)
          .set(AuthenticationStatus.authenticated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, WidgetRef ref, __) {
        final authenticationProvider = ref.watch(authenticationServiceProvider);

        setDeviceId(ref, widget._deviceId);

        setAuth(ref);

        /// 스플래시는 네이티브(Android Theme.SplashScreen, iOS LaunchScreen)가 그린다.
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: nbkNavigatorKey,
            theme: NbkTheme.light,
            themeMode: ThemeMode.light,
            home: authenticationProvider == AuthenticationStatus.authenticated
                ? const HomePageRefactor()
                : const HomePageRefactor()

            /*
          authenticationProvider == AuthenticationStatus.authenticated
              ? const HomePage(
                  homeBottomStatus: HomeBottomStatus.home,
                  homeAppbarStatus: HomeAppbarStatus.whole,
                )
              : const HomePage(
                  homeBottomStatus: HomeBottomStatus.home,
                  homeAppbarStatus: HomeAppbarStatus.whole,
                )
           */
            );
      },
    );
  }
}
