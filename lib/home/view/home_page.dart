import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/board/board.dart';
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

      // getBoard 통신 예시코드
      //exampleGetBoard(ref);

      exampleGetRankTab(ref, 0, 3);

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
              ),
            if(homeAppbarNavigation == HomeAppbarStatus.whole)
              NurbanBoardItemView(
                title: 'title',
                lossCut: 'dflkj',
                author: 'dflkdjf',
                date: '2012-12-21',
                likeCount: '34',
                thumbnail: Assets.images.home.nurbanSymbol.image(),
              ),
            if(homeAppbarNavigation == HomeAppbarStatus.whole)
              const FreeBoardItemView(
                title: 'title',
                content: 'content',
                author: 'dflkdjf',
                date: '2012-12-21',
                likeCount: '34',
              ),
          ],
        );
    });
  }

  void exampleGetBoard(WidgetRef ref){
    final getBoard = ref.read(getBoardProvider);
    log('getBoard: $getBoard');
    getBoard.when(
      data: (data) async {
        final receiveData = await data;
        log('getBoard data: $data');
        log('getBoard data receiveData : $receiveData');
        for (var element in receiveData) {
          log('getBoard data id: ${element.id}');
          log('getBoard data type: ${element.type}');
          log('getBoard data name: ${element.name}');
          log('getBoard data address: ${element.address}');
        }
      },
      loading: () {
        log('getBoard loading');
      },
      error: (error, stackTrace) {
        log('getBoard error: $error');
      },
    );
  }

  void exampleGetRankTab(WidgetRef ref, int offset, int limit){
    final getRankTab = ref.read(getRankTabProvider((offset: offset,limit: limit)));
    log('getRankTab: $getRankTab');
    getRankTab.when(
      data: (data) async {
        final receiveData = await data;
        log('getRankTab data: $data');
        log('getRankTab data receiveData : $receiveData');
        for (var element in receiveData) {
          log('getRankTab data id: ${element.id}');
          log('getRankTab data userId: ${element.userId}');
          log('getRankTab data badge: ${element.badge}');
          log('getRankTab data nickname: ${element.nickname}');
          log('getRankTab data insignia: ${element.insignia}');
        }
      },
      loading: () {
        log('getRankTab loading');
      },
      error: (error, stackTrace) {
        log('getRankTab error: $error');
      },
    );
  }

}

