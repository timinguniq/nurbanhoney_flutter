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

      //exampleGetRankTab(ref, 0, 3);


      return Stack(children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const AppbarBottom(),
              const SizedBox(
                height: 16,
              ),
              if (homeAppbarNavigation == HomeAppbarStatus.whole)
                NurbanRankTabView(
                  rankLength: 3,
                  onTap: () {
                    log('전체보기 클릭');
                  },
                ),
              const SizedBox(
                height: 16,
              ),
              if (homeAppbarNavigation == HomeAppbarStatus.whole)
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
                const BoardAllView(
                  flag: 0,
                  articleId: -1,
                  limit: 100,
                ),


            ],
          ),

        ),
      ]);
    });
  }

  void exampleGetBoard(WidgetRef ref) {
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

  void exampleGetBoardAll(WidgetRef ref, int flag, int articleId, int limit) {
    final getBoardAll = ref.watch(getBoardAllProvider((flag, articleId, limit)));
    log('getBoardAll: $getBoardAll');
    getBoardAll.when(
      data: (data) async {
        final receiveData = await data;
        log('getBoardAll data: $data');
        log('getBoardAll data receiveData : $receiveData');
        for (var element in receiveData) {
          log('getBoardAll data id: ${element.id}');
          log('getBoardAll data board: ${element.board}');
          log('getBoardAll data thumbnail: ${element.thumbnail}');
          log('getBoardAll data title: ${element.title}');
          log('getBoardAll data content: ${element.content}');
          log('getBoardAll data commentCount: ${element.commentCount}');
          log('getBoardAll data likeCount: ${element.likeCount}');
          log('getBoardAll data createdAt: ${element.createdAt}');
          log('getBoardAll data nickname: ${element.nickname}');
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

  void exampleGetRankTab(WidgetRef ref, int offset, int limit) {
    final getRankTab =
    ref.watch(getRankTabProvider((offset: offset, limit: limit)));
    log('getRankTab: $getRankTab');
    getRankTab.when(
      data: (data) {
        final receiveData = data;
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
