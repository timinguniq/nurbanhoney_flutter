import 'dart:developer';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class DrawerProfilePreview extends StatelessWidget {
  const DrawerProfilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      final authenticationProvider = ref.watch(authenticationServiceProvider);
      //const authenticationProvider = AuthenticationStatus.authenticated;

      // TODO: 프로필 데이터 받아오는 통신해야 될듯 그래서 아래 Auth에 닉네임과 섬네일 넣어줘야 될 듯

      final drawerProfileTextStyle = ref.read(drawerProfileStyle);
      final drawerProfileEditTextStyle = ref.read(drawerProfileEditStyle);
      final loginButtonColor = ref.read(colorF6B748);

      return authenticationProvider == AuthenticationStatus.authenticated
          ? DrawerProfilePreviewAuth(
              thumbnail: Assets.images.login.kakaoSymbol.image(),
              nickname: '닉네임',
              onTap: (){
                log('edit profile clicked');
              },
              drawerProfileTextStyle: drawerProfileTextStyle,
            )
          : DrawerProfilePreviewUnAuth(
              drawerProfileTextStyle: drawerProfileTextStyle,
              drawerProfileEditTextStyle: drawerProfileEditTextStyle,
              loginButtonColor: loginButtonColor,
            );
    });
  }
}

class DrawerProfilePreviewAuth extends StatelessWidget {
  const DrawerProfilePreviewAuth({
    required Image thumbnail,
    required String nickname,
    required VoidCallback? onTap,
    required TextStyle drawerProfileTextStyle,
    super.key})
      : _thumbnail = thumbnail,
        _nickname = nickname,
        _onTap = onTap,
        _drawerProfileTextStyle = drawerProfileTextStyle;

  final Image _thumbnail;
  final String _nickname;
  final VoidCallback? _onTap;
  final TextStyle _drawerProfileTextStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 50,
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _thumbnail,
            ),
          ),
          const Expanded(
            flex: 15,
            child: SizedBox(),
          ),
          Text(
            _nickname,
            style: _drawerProfileTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
          const Expanded(
            flex: 96,
            child: SizedBox(),
          ),
          InkWell(
            onTap: _onTap,
            child: SizedBox(
              width: 21,
              height: 21,
              child: Assets.images.home.drawerProfileEdit.image(),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerProfilePreviewUnAuth extends StatelessWidget {
  const DrawerProfilePreviewUnAuth({
    required TextStyle drawerProfileTextStyle,
    required TextStyle drawerProfileEditTextStyle,
    required Color loginButtonColor,
    super.key
  }): _drawerProfileTextStyle = drawerProfileTextStyle,
      _drawerProfileEditTextStyle = drawerProfileEditTextStyle,
      _loginButtonColor = loginButtonColor;

  final TextStyle _drawerProfileTextStyle;
  final TextStyle _drawerProfileEditTextStyle;
  final Color _loginButtonColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 50,
      child: Row(
        children: [
          Text(
            '로그인 후\n이용해 주세요.',
            style: _drawerProfileTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
          const Expanded(
            child: SizedBox(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(LoginPage.route());
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: _loginButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              '로그인',
              style: _drawerProfileEditTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
