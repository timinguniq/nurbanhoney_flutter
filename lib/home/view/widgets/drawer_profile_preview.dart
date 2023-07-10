import 'dart:developer';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/login/login.dart';

class DrawerProfilePreview extends StatelessWidget {
  const DrawerProfilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);
      const authenticationProvider = AuthenticationStatus.authenticated;
      return authenticationProvider == AuthenticationStatus.authenticated
          ? DrawerProfilePreviewAuth(
              thumbnail: Assets.images.login.kakaoSymbol.image(),
              nickname: '닉네임',
              onTap: (){
                log('edit profile clicked');
              },
            )
          : DrawerProfilePreviewUnAuth();
    });
  }
}

class DrawerProfilePreviewAuth extends StatelessWidget {
  const DrawerProfilePreviewAuth({
    required Image thumbnail,
    required String nickname,
    required VoidCallback? onTap,
    super.key})
      : _thumbnail = thumbnail,
        _nickname = nickname,
        _onTap = onTap;

  final Image _thumbnail;
  final String _nickname;
  final VoidCallback? _onTap;

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
  const DrawerProfilePreviewUnAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 50,
      child: Row(
        children: [
          Text(
            '로그인 후\n이용해 주세요.',
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: SizedBox(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(LoginPage.route());
            },
            child: Text(
              '로그인',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
