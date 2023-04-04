import 'dart:async';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        // TODO : 여기에 딜레이 걸어서 화면 변화 테스트해보기.
        Timer(const Duration(seconds: 5), (){
          /// 사실상 필요 없으나 예시코드.
          ref.read(authenticationServiceProvider.notifier).state = AuthenticationStatus.authenticated;
        });

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: standard,
          home: authenticationProvider == AuthenticationStatus.authenticated
              ? Scaffold(
                  body: Center(
                    child: Text('auth'),
                  ),
                )
              :Scaffold(
                  body: Center(
                    child: Text('unauth'),
                  ),
                )
        );
      },
    );
  }
}

