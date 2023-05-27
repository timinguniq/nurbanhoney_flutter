import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/home/home.dart';

// 전체, 인기글, 너반꿀, 자유게시판이 있는 버튼
class AppbarBottom extends StatelessWidget{
  const AppbarBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final homeAppbarNavigation = ref.watch(homeAppbarNavigationProvider);
      // TODO : 여기에 딜레이 걸어서 화면 변화 테스트해보기.
      /*
        Timer(const Duration(seconds: 5), (){
          /// 사실상 필요 없으나 예시코드.
          ref.read(authenticationServiceProvider.notifier).state = AuthenticationStatus.authenticated;
        });
        */

      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppbarDivider(),
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: AppbarBottomIcon(
                        isSelected: homeAppbarNavigation == HomeAppbarStatus.whole,
                        text: '전체',
                        onTap: () => ref.read(homeAppbarNavigationProvider.notifier).select(HomeAppbarStatus.whole),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: AppbarBottomIcon(
                        isSelected: homeAppbarNavigation == HomeAppbarStatus.popular,
                        text: '인기글',
                        onTap: () => ref.read(homeAppbarNavigationProvider.notifier).select(HomeAppbarStatus.popular),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: AppbarBottomIcon(
                        isSelected: homeAppbarNavigation == HomeAppbarStatus.nurban,
                        text: '너반꿀',
                        onTap: () => ref.read(homeAppbarNavigationProvider.notifier).select(HomeAppbarStatus.nurban),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: AppbarBottomIcon(
                        isSelected: homeAppbarNavigation == HomeAppbarStatus.free,
                        text: '자유게시판',
                        onTap: () => ref.read(homeAppbarNavigationProvider.notifier).select(HomeAppbarStatus.free),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AppbarDivider(),
          ],
        ),
      );
    });
  }
}
