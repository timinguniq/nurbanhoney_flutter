import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const HomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            SizedBox(
              width: 30,
              height: 25,
              child: Assets.images.home.nurbanSymbol.image(),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 55,
              height: 20,
              child: Assets.images.home.nurbanChar.image(),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              log('toolbar clicked');
            },
            icon: SizedBox(
              width: 20,
              height: 15,
              child: Assets.images.home.homeToolbar.image(),
            ),
          ),
        ],
      ),
      body: const HomeBodyView(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeBodyView extends StatelessWidget {
  const HomeBodyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final homeAppbarNavigation = ref.watch(homeAppbarNavigationProvider);
      log('homeAppbarNavigation : $homeAppbarNavigation');

      final colorDivider = ref.read(colorEFEFEF);
      final homeDividerStyle = ref.read(homeDividerTitle);
      return Column(
          children: [
            const AppbarBottom(),
            const SizedBox(
              height: 16,
            ),
            if(homeAppbarNavigation == HomeAppbarStatus.whole)
              NurbanRankTabView(
                rankLength: 3,
                onTap: (){
                  log('전체보기 클릭');
                },
              ),
            const SizedBox(
              height: 16,
            ),
            if(homeAppbarNavigation == HomeAppbarStatus.whole)
              Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                height: 32,
                color: colorDivider,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '최신순',
                    style: homeDividerStyle,
                  ),
                ),
              )
          ],
        );
    });

  }
}

