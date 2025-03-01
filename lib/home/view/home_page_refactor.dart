import 'dart:developer';

import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/home/view/widgets/drawer_profile.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

import 'package:nurbanhoney/stock/stock.dart';
import 'package:nurbanhoney/coin/coin.dart';

class HomePageRefactor extends StatelessWidget {
  const HomePageRefactor({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const HomePageRefactor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HomeViewRefactor();
  }
}

class HomeViewRefactor extends ConsumerStatefulWidget {
  const HomeViewRefactor({
    super.key,
  });

  @override
  ConsumerState<HomeViewRefactor> createState() => _HomeViewRefactorState();
}

class _HomeViewRefactorState extends ConsumerState<HomeViewRefactor> {
  final List<Widget> _widgetOptions = const <Widget>[
    StockTabPage(),
    CoinTabPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tabSelectedColor = ref.read(colorF6B748);
    final tabUnselectedColor = ref.read(color212124);
    final authenticationProvider = ref.watch(authenticationServiceProvider);

    final homeTabTextStyle = ref.read(homeTabStyle);

    final homeBottomNavigation = ref.watch(homeBottomNavigationProvider);
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 0) {
          log('Swiping in right direction');
        }

        // Swiping in left direction.
        if (details.delta.dx < 0) {
          log('Swiping in left direction');
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                TabBar(
                  indicatorColor: tabSelectedColor,
                  unselectedLabelColor: tabUnselectedColor,
                  labelStyle: homeTabTextStyle,
                  indicatorWeight: 2,
                  tabs: const [
                    Tab(
                      text: '주식',
                      height: 50,
                    ),
                    Tab(
                      text: '코인',
                      height: 50,
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _widgetOptions[0],
                      _widgetOptions[1],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
