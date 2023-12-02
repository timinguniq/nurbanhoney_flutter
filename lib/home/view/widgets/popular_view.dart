import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/board/board.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:share_service/share_service.dart';

class PopularView extends StatelessWidget {
  const PopularView(
      { required int articleId,
        required int limit,
        super.key})
      : _articleId = articleId,
        _limit = limit;

  final int _articleId;
  final int _limit;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final rankTabTitleStyle = ref.watch(rankTabTitle);
      //final rankTabWholeStyle = ref.watch(rankTabWhole);
      final getPopularAll =
      ref.watch(getPopularAllProvider((_articleId, _limit)));
      final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);

      return getPopularAll.when(
        data: (data) {
          final receiveData = data;
          log('getPopularAll data: $data');
          log('getPopularAll data receiveData : $receiveData');
          for (var element in receiveData) {
            log('getPopularAll data id: ${element.id}');
            log('getPopularAll data board: ${element.board}');
            log('getPopularAll data thumbnail: ${element.thumbnail}');
            log('getPopularAll data title: ${element.title}');
            log('getPopularAll data content: ${element.content}');
            log('getPopularAll data commentCount: ${element.commentCount}');
            log('getPopularAll data likeCount: ${element.likeCount}');
            log('getPopularAll data createdAt: ${element.createdAt}');
            log('getPopularAll data nickname: ${element.nickname}');
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                for (var i = 0 ; i < receiveData.length ; i++)
                  receiveData[i].board == 1
                      ? Column(
                    children: [
                      NurbanBoardItemView(
                        badge: RankBoardBadge(
                          rank: i + 1,
                        ),
                        title: receiveData[i].title,
                        lossCut: receiveData[i].lossCut,
                        author: receiveData[i].nickname,
                        date: formattingCreatedAt(receiveData[i].createdAt),
                        likeCount: receiveData[i].likeCount,
                        thumbnail: CachedNetworkImage(
                          imageUrl: receiveData[i].thumbnail ?? '',
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              CircularProgressIndicator(value: downloadProgress.progress),
                          errorWidget: (context, url, error) => Assets.images.home.nurbanSymbol.image(),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(ArticleDetailPage.route(
                            board: receiveData[i].board,
                            articleId: receiveData[i].id,
                          ));
                        },
                      ),
                      const AppbarDivider(),
                    ],
                  )
                      : receiveData[i].board == 2
                      ? Column(
                    children: [
                      FreeBoardItemView(
                        badge: RankBoardBadge(
                          rank: i + 1,
                        ),
                        title: receiveData[i].title,
                        content: receiveData[i].content,
                        author: receiveData[i].nickname,
                        date: formattingCreatedAt(receiveData[i].createdAt),
                        likeCount: receiveData[i].likeCount,
                        onTap: () {
                          Navigator.of(context)
                              .push(ArticleDetailPage.route(
                            board: receiveData[i].board,
                            articleId: receiveData[i].id,
                          ));
                        },
                      ),
                      const AppbarDivider(),
                    ],
                  )
                      : Column(
                    children: [
                      FreeBoardItemView(
                        badge: RankBoardBadge(
                          rank: i + 1,
                        ),
                        title: receiveData[i].title,
                        content: receiveData[i].content,
                        author: receiveData[i].nickname,
                        date: formattingCreatedAt(receiveData[i].createdAt),
                        likeCount: receiveData[i].likeCount,
                        onTap: () {
                          Navigator.of(context)
                              .push(ArticleDetailPage.route(
                            board: receiveData[i].board,
                            articleId: receiveData[i].id,
                          ));
                        },
                      ),
                      const AppbarDivider(),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () {
          log('getPopularAll loading');
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('getPopularAll error: $error');
          return const Text('error');
        },
      );
    });
  }
}
