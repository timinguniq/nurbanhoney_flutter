import 'dart:developer';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

class DrawerProfilePreview extends StatelessWidget {
  const DrawerProfilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      final authenticationProvider = ref.watch(authenticationServiceProvider);
      //const authenticationProvider = AuthenticationStatus.authenticated;

      // TODO: 프로필 데이터 받아오는 통신해야 될듯 그래서 아래 Auth에 닉네임과 섬네일 넣어줘야 될 듯
      final prefStorageProvider = ref.watch(preferenceStorageProvider);
      final prefStorage = prefStorageProvider.asData?.value;
      final token = prefStorage?.getToken() ?? '__empty__';
      log('drawer_profile_preview token: $token');
      var thumbnail = '';
      var nickname = '';

      if(token != '__empty__'){
        final profileProvider = ref.watch(getProfileProvider(token));
        final profileRecord = profileProvider.value;
        final convertToInsigniaFunc = ref.read(convertToInsignia);

        if(profileRecord != null){
          log('drawer_profile_preview profileRecord: $profileRecord');
          log('drawer_profile_preview profileRecord id: ${profileRecord.id}');
          log('drawer_profile_preview profileRecord loginType: ${profileRecord.loginType}');
          log('drawer_profile_preview profileRecord badge: ${profileRecord.badge}');
          log('drawer_profile_preview profileRecord nickname: ${profileRecord.nickname}');
          log('drawer_profile_preview profileRecord description: ${profileRecord.description}');
          log('drawer_profile_preview profileRecord point: ${profileRecord.point}');
          log('drawer_profile_preview profileRecord insigniaShow: ${profileRecord.insigniaShow}');
          log('drawer_profile_preview profileRecord insigniaOwn: ${profileRecord.insigniaOwn}');
          log('drawer_profile_preview profileRecord myArticleCount: ${profileRecord.myArticleCount}');
          log('drawer_profile_preview profileRecord myCommentCount: ${profileRecord.myCommentCount}');

          // insighiaShow, insighiaOwn String을 List로 바꾸는 코드 예시
          final lInsigniaShow = convertToInsigniaFunc(profileRecord.insigniaShow);
          final lInsigniaOwn = convertToInsigniaFunc(profileRecord.insigniaOwn);

          thumbnail = profileRecord.badge;
          nickname = profileRecord.nickname;
        }
      }

      final drawerProfileTextStyle = ref.read(drawerProfileStyle);
      final drawerProfileEditTextStyle = ref.read(drawerProfileEditStyle);
      final loginButtonColor = ref.read(colorF6B748);

      return authenticationProvider == AuthenticationStatus.authenticated
          ? DrawerProfilePreviewAuth(
              thumbnail: thumbnail,
              nickname: nickname,
              onTap: (){
                log('edit profile clicked');

                // TODO: 아직 edit 페이지가 없음 나중에 edit 페이지로 이동.
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
    required String thumbnail,
    required String nickname,
    required VoidCallback? onTap,
    required TextStyle drawerProfileTextStyle,
    super.key})
      : _thumbnail = thumbnail,
        _nickname = nickname,
        _onTap = onTap,
        _drawerProfileTextStyle = drawerProfileTextStyle;

  final String _thumbnail;
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
              child: CachedNetworkImage(
                imageUrl: _thumbnail,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
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
