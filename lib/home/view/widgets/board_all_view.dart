import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/board/board.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';

class BoardAllView extends StatelessWidget {
  const BoardAllView({
    required int flag,
    required int articleId,
    required int limit,
    super.key})
    : _flag = flag,
      _articleId = articleId,
      _limit = limit;

  final int _flag;
  final int _articleId;
  final int _limit;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final rankTabTitleStyle = ref.watch(rankTabTitle);
      //final rankTabWholeStyle = ref.watch(rankTabWhole);

      final getBoardAll = ref.watch(getBoardAllProvider((_flag, _articleId, _limit)));

      return getBoardAll.when(
        data: (data) {
          final receiveData = data;
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
          return SingleChildScrollView(
            child: Column(
              children: [
                for(var element in receiveData)
                  if(element.board == 0)
                    FreeBoardItemView(
                      title: element.title,
                      content: element.content,
                  SizedBox(),


                if (homeAppbarNavigation == HomeAppbarStatus.whole)
                  NurbanBoardItemView(
                    title: 'title',
                    lossCut: 'dflkj',
                    author: 'dflkdjf',
                    date: '2012-12-21',
                    likeCount: '34',
                    thumbnail: Assets.images.home.nurbanSymbol.image(),
                  ),
                if (homeAppbarNavigation == HomeAppbarStatus.whole)
                  const FreeBoardItemView(
                    title: 'title',
                    content: 'content',
                    author: 'dflkdjf',
                    date: '2012-12-21',
                    likeCount: '34',
                  ),

              ],
            ),
          );
        },
        loading: () {
          log('getBoardAll loading');
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('getBoardAll error: $error');
          return const Text('error');
        },
      );

    });
  }
}
