import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/splash/splash.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppView();
  }
}

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, WidgetRef ref, __){
        final standard = ref.watch(standardTheme);
        final authenticationProvider = ref.watch(authenticationServiceProvider);
        
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

