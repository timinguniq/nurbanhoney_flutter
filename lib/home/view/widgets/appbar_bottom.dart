import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/home/home.dart';

class AppbarBottom extends StatelessWidget implements PreferredSizeWidget {
  const AppbarBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (_, WidgetRef ref, __) {
          final homeAppbarNavigation = ref.watch(homeAppbarNavigationProvider);
          // TODO : 여기에 딜레이 걸어서 화면 변화 테스트해보기.
          /*
        Timer(const Duration(seconds: 5), (){
          /// 사실상 필요 없으나 예시코드.
          ref.read(authenticationServiceProvider.notifier).state = AuthenticationStatus.authenticated;
        });
        */
          return SizedBox(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppbarDivider(),
                Expanded(
                  child: Row(
                    children: [
                      AppbarBottomIcon(
                        isSelected: homeAppbarNavigation == HomeAppbarStatus.whole,
                        text: '전체',
                      ),
                      AppbarBottomIcon(
                        isSelected: homeAppbarNavigation == HomeAppbarStatus.popular,
                        text: '인기글',
                      ),

                    ],
                  ),
                ),
                const AppbarDivider(),
              ],
            ),
          );

        }
    );

  }

  @override
  Size get preferredSize => const Size(double.infinity, 50);
}
