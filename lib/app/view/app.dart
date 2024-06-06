import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/splash/splash.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, WidgetRef ref, __) {
        final standard = ref.watch(standardTheme);
        final authenticationProvider = ref.watch(authenticationServiceProvider);

        setDeviceId(ref, widget._deviceId);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: standard,
          onGenerateRoute: (_) => SplashPage.route(),
          home: authenticationProvider == AuthenticationStatus.authenticated
              ? const HomePage(
                  homeBottomStatus: HomeBottomStatus.home,
                  homeAppbarStatus: HomeAppbarStatus.whole,
                )
              : const HomePage(
                  homeBottomStatus: HomeBottomStatus.home,
                  homeAppbarStatus: HomeAppbarStatus.whole,
                )
        );
      },
    );
  }

}

