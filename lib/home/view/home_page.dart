import 'dart:developer';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/board/board.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/login/login.dart';
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
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeBodyView(),
    HoneyRankBodyView(),
    MyaccountBodyView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final floatButtonColor = ref.read(colorF6B748);
      final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Scaffold(
        extendBody: true,
        appBar: _selectedIndex != 2
            ? PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: AppBar(
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
              )
            : PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Center(child: Text('마이페이지')),
                ),
              ),
        body: _widgetOptions.elementAt(_selectedIndex),
        floatingActionButton: _selectedIndex != 2
            ? FloatingActionButton(
                onPressed: () {
                  if(authenticationProvider == AuthenticationStatus.authenticated) {
                    // TODO : 글 생성 화면으로 이동.
                    //Navigator.of(context).push(BoardPage.routeName);
                  } else {
                    // TODO : 로그인 화면으로 이동
                    Navigator.of(context).push(LoginPage.route());
                  }
                },
                backgroundColor: floatButtonColor,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Assets.images.home.floatingButton.image(),
                ),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: SizedBox(
                width: 32,
                height: 32,
                child: Assets.images.home.naviHomeInactive.image(),
              ),
              activeIcon: SizedBox(
                width: 32,
                height: 32,
                child: Assets.images.home.naviHomeActive.image(),
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                width: 32,
                height: 32,
                child: Assets.images.home.naviRankInactive.image(),
              ),
              activeIcon: SizedBox(
                width: 32,
                height: 32,
                child: Assets.images.home.naviRankActive.image(),
              ),
              label: '꿀랭킹',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                width: 32,
                height: 32,
                child: Assets.images.home.naviMyaccountInactive.image(),
              ),
              activeIcon: SizedBox(
                width: 32,
                height: 32,
                child: Assets.images.home.naviMyaccountActive.image(),
              ),
              label: '내 정보',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: floatButtonColor,
          onTap: _onItemTapped,
        ),
      );
    });
  }
}
