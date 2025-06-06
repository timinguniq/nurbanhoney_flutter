import 'dart:developer';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
  });

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SplashPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SplashView();
  }
}

class SplashView extends StatefulWidget {
  const SplashView({
    super.key,
  });

  void showHome({
    required BuildContext context,
  }) {
    Navigator.of(context).pushAndRemoveUntil<void>(
      HomePage.route(),
      (route) => false,
    );
  }

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('SplashPage token0:');

    // Home page will be shown after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) widget.showHome(context: context);
    });

    return Consumer(
      builder: (_, WidgetRef ref, __) {
        final style = ref.read(overlayStyle);
        SystemChrome.setSystemUIOverlayStyle(style);

        return Scaffold(
          body: Center(
            child: SizedBox(
              width: 70,
              height: 100,
              child: Assets.images.splash.splash.image(),
            ),
          ),
        );
      },
    );
  }
}
