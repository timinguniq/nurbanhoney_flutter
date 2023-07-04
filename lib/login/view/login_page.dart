import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final titleStyle = ref.read(loginTitleStyle);
      // 카카오와 구글은 텍스트 스타일이 같다.
      final kakaoStyle = ref.read(loginKakaoStyle);
      final naverStyle = ref.read(loginNaverStyle);
      final noticeStyle = ref.read(loginNoticeStyle);
      final noticeHighlightStyle = ref.read(loginNoticeHighlightStyle);

      final kakaoBackgroundColor = ref.read(colorFEE500);
      final naverBackgroundColor = ref.read(color00C85A);

      return Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 9,
                    left: 10,
                  ),
                  child: Assets.images.login.loginClose.image(
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const Expanded(
                flex: 156,
                child: SizedBox(),
              ),
              Text(
                '로그인 방법을 선택하세요',
                style: titleStyle,
              ),
              const Expanded(
                flex: 64,
                child: SizedBox(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SocialLoginBtn(
                  icon: Assets.images.login.kakaoSymbol.image(),
                  text: '카카오톡 계정으로 로그인',
                  textStyle: kakaoStyle,
                  backgroundColor: kakaoBackgroundColor,
                  elevation: 0,
                  onTap: () {
                    log('kakao login click');
                  },
                ),
              ),
              const Expanded(
                flex: 21,
                child: SizedBox(),
              ),
              const Expanded(
                flex: 21,
                child: SizedBox(),
              ),
              const Expanded(
                flex: 218,
                child: SizedBox(),
              ),
              const Expanded(
                flex: 19,
                child: SizedBox(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
