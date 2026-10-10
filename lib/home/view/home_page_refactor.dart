import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/account/account.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/ranking/ranking.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 앱의 루트 화면. 하단 탭(홈 / 랭킹 / 내 계정)으로 세 탭 페이지를 전환한다.
/// 탭 상태는 [homeBottomNavigationProvider] 가 갖고, 다른 화면(Top3 전체보기, 내 순위 바)도 이 provider 로 탭을 바꾼다.
class HomePageRefactor extends StatelessWidget {
  const HomePageRefactor({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const HomePageRefactor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HomeShell();
  }
}

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static NbkTab _tabOf(HomeBottomStatus status) => switch (status) {
        HomeBottomStatus.rank => NbkTab.ranking,
        HomeBottomStatus.myaccount => NbkTab.account,
        HomeBottomStatus.home || HomeBottomStatus.unknown => NbkTab.home,
      };

  static HomeBottomStatus _statusOf(NbkTab tab) => switch (tab) {
        NbkTab.home => HomeBottomStatus.home,
        NbkTab.ranking => HomeBottomStatus.rank,
        NbkTab.account => HomeBottomStatus.myaccount,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = _tabOf(ref.watch(homeBottomNavigationProvider));

    return Scaffold(
      body: LazyIndexedStack(
        index: tab.index,
        children: const [
          HomeTabView(),
          RankingTabPage(),
          AccountTabPage(),
        ],
      ),
      bottomNavigationBar: NbkBottomTabBar(
        current: tab,
        onSelect: (selected) =>
            ref.read(homeBottomNavigationProvider.notifier).select(_statusOf(selected)),
      ),
    );
  }
}
