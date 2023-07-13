import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
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
      final primaryColor = ref.read(colorF6B748);

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
                  onTap: () async {
                    log('kakao login click');

                    await kakaoLogin();

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
                    _devPopup(
                      context: context,
                      content: '네이버 로그인 개발 중입니다.',
                      confirmColor: primaryColor,
                    );
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
                    _devPopup(
                      context: context,
                      content: '구글 로그인 개발 중입니다.',
                      confirmColor: primaryColor,
                    );
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
                    confirmColor: primaryColor,
                  );
                },
                privacyPolicyOnTap: () {
                  log('privacy policy click');
                  _policyPopup(
                    context: context,
                    content: 'privacy policy click',
                    confirmColor: primaryColor,
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
    required Color confirmColor,
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
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: confirmColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  // 개발중 팝업
  void _devPopup({
    required BuildContext context,
    required String content,
    required Color confirmColor,
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
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: confirmColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  // 빈 문자열을 리턴하면 로그인 실패
  // 로그인에 성공하면 kakao accessToken을 리턴
  Future<String> kakaoLogin() async{
    var accessToken = '';
    // 카카오톡 설치 여부 확인
    // 카카오톡이 설치되어 있으면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        final oAuthToken = await UserApi.instance.loginWithKakaoTalk();
        accessToken = oAuthToken.accessToken;
        log('카카오톡으로 로그인 성공');
      } catch (error) {
        log('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return '';
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          final oAuthToken = await UserApi.instance.loginWithKakaoAccount();
          accessToken = oAuthToken.accessToken;
          log('카카오계정으로 로그인 성공');
        } catch (error) {
          log('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        final oAuthToken = await UserApi.instance.loginWithKakaoAccount();
        accessToken = oAuthToken.accessToken;
        log('카카오계정으로 로그인 성공');
      } catch (error) {
        log('카카오계정으로 로그인 실패 $error');
      }
    }

    return accessToken;
  }
}
