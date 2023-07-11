import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class DrawerProfile extends StatelessWidget {
  const DrawerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final drawerProfileTextStyle = ref.read(drawerProfileStyle);
      final dividerColor = ref.read(color55000000);

      return  Drawer(
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Assets.images.login.loginClose.image(),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Center(
                  child: DrawerProfilePreview(),
              ),
              const SizedBox(
                height: 22,
              ),
              Divider(
                thickness: 0.5,
                color: dividerColor,
              ),
              const SizedBox(
                height: 14,
              ),
              DrawerBoardWidget(
                title: '공지사항',
                textStyle: drawerProfileTextStyle,
                onTap: () {
                  log('notice clicked');
                },
              ),
              const SizedBox(
                height: 10,
              ),
              DrawerBoardWidget(
                title: '인기글',
                textStyle: drawerProfileTextStyle,
                onTap: () {
                  log('popular clicked');
                },
              ),
              const SizedBox(
                height: 10,
              ),
              DrawerBoardWidget(
                title: '너반꿀 랭킹(꿀랭)',
                textStyle: drawerProfileTextStyle,
                onTap: () {
                  log('nurban rank clicked');
                },
              ),
              const SizedBox(
                height: 14,
              ),
              Divider(
                thickness: 0.5,
                color: dividerColor,
              ),
            ],
          ),
        ),
      );
    });
  }
}
