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
      final whiteColor = ref.read(primaryWhite);

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
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SocialLoginBtn(
                  icon: Assets.images.login.naverSymbol.image(),
                  text: '네이버 계정으로 로그인',
                  textStyle: naverStyle,
                  backgroundColor: naverBackgroundColor,
                  elevation: 0,
                  onTap: () {
                    log('naver login click');
                  },
                ),
              ),
              const Expanded(
                flex: 21,
                child: SizedBox(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SocialLoginBtn(
                  icon: Assets.images.login.googleSymbol.image(),
                  text: '구글 계정으로 로그인',
                  textStyle: kakaoStyle,
                  backgroundColor: whiteColor,
                  elevation: 2,
                  onTap: () {
                    log('google login click');
                  },
                ),
              ),
              const Expanded(
                flex: 218,
                child: SizedBox(),
              ),
              LoginNotice(
                text1: '회원가입 없이 이용가능 하며 첫 로그인시 ',
                text2: '이용약관 ',
                text3: '및',
                text4: '개인정보 처리방침 ',
                text5: '동의로 간주됩니다.',
                textStyle: noticeStyle,
                highlightTextStyle: noticeHighlightStyle,
                termsOfUseOnTap: () {
                  log('terms of use click');
                  _policyPopup(
                    context: context,
                    content: 'terms of use click',
                  );
                },
                privacyPolicyOnTap: () {
                  log('privacy policy click');
                  _policyPopup(
                    context: context,
                    content: 'privacy policy click',
                  );
                },
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

  // 이용약관과 개인정보 처리방침 팝업
  void _policyPopup({
    required BuildContext context,
    required String content,
  }) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(content),
            insetPadding: const EdgeInsets.fromLTRB(10, 80, 10, 80),
            actions: [
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
