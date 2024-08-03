import 'dart:developer';

import 'package:android_id/android_id.dart';
import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required HomeBottomStatus homeBottomStatus,
    required HomeAppbarStatus homeAppbarStatus,
    super.key,
  })  : _homeBottomStatus = homeBottomStatus,
        _homeAppbarStatus = homeAppbarStatus;

  final HomeBottomStatus _homeBottomStatus;
  final HomeAppbarStatus _homeAppbarStatus;

  static Route route({
    HomeBottomStatus homeBottomStatus = HomeBottomStatus.home,
    HomeAppbarStatus homeAppbarStatus = HomeAppbarStatus.whole,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => HomePage(
        homeBottomStatus: homeBottomStatus,
        homeAppbarStatus: homeAppbarStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeView(
      homeBottomStatus: _homeBottomStatus,
      homeAppbarStatus: _homeAppbarStatus,
    );
  }
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({
    required HomeBottomStatus homeBottomStatus,
    required HomeAppbarStatus homeAppbarStatus,
    Key? key,
  })  : _homeBottomStatus = homeBottomStatus,
        _homeAppbarStatus = homeAppbarStatus,
        super(key: key);

  final HomeBottomStatus _homeBottomStatus;
  final HomeAppbarStatus _homeAppbarStatus;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeBodyView(),
    HoneyRankBodyView(),
    MyaccountBodyView(),
  ];

  @override
  void initState() {
    super.initState();
    switch (widget._homeBottomStatus) {
      case HomeBottomStatus.home:
        _selectedIndex = 0;
        break;
      case HomeBottomStatus.rank:
        _selectedIndex = 1;
        break;
      case HomeBottomStatus.myaccount:
        _selectedIndex = 2;
        break;
      case HomeBottomStatus.unknown:
        _selectedIndex = 0;
        break;
    }

    Future.delayed(const Duration(milliseconds: 10), () {
      switch (widget._homeAppbarStatus) {
        case HomeAppbarStatus.whole:
          ref.read(homeAppbarNavigationProvider.notifier)
              .select(HomeAppbarStatus.whole);
          break;
        case HomeAppbarStatus.popular:
          ref.read(homeAppbarNavigationProvider.notifier)
              .select(HomeAppbarStatus.popular);
          break;
        case HomeAppbarStatus.nurban:
          ref.read(homeAppbarNavigationProvider.notifier)
              .select(HomeAppbarStatus.nurban);
          break;
        case HomeAppbarStatus.free:
          ref.read(homeAppbarNavigationProvider.notifier)
              .select(HomeAppbarStatus.free);
          break;
        case HomeAppbarStatus.unknown:
          ref.read(homeAppbarNavigationProvider.notifier)
              .select(HomeAppbarStatus.whole);
          break;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final floatButtonColor = ref.read(colorF6B748);
    final authenticationProvider = ref.watch(authenticationServiceProvider);

    final myaccountTitleTextStyle = ref.read(myaccountTitleStyle);

    final homeBottomNavigation = ref.watch(homeBottomNavigationProvider);
    return Scaffold(
      extendBody: true,
      appBar: _selectedIndex != 2
          ? PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
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
                /*
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

                   */
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Center(
                    child: Text(
                      '마이페이지',
                      style: myaccountTitleTextStyle,
                    ),
                ),
              ),
            ),
      endDrawer: const DrawerProfile(),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex != 2
          ? FloatingActionButton(
              onPressed: () {
                if (authenticationProvider ==
                    AuthenticationStatus.authenticated) {
                  //Navigator.of(context).push(BoardPage.routeName);
                  Navigator.of(context).push(ArticleCreatePage.route());
                } else {
                  Navigator.of(context).push(LoginPage.route());
                }
              },
              backgroundColor: floatButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Assets.images.home.floatingButton.image(),
              )
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
  }
}
