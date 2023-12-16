import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/board/board.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:share_service/share_service.dart';

class RankView extends StatelessWidget {
  const RankView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final rankTabTitleStyle = ref.watch(rankTabTitle);
      //final rankTabWholeStyle = ref.watch(rankTabWhole);
      // TODO: rank View 통신 바꿔야 됨.
      final getRankAll =
      ref.watch(getRankProvider);
      final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);

      final colorDivider = ref.read(colorEFEFEF);

      return getRankAll.when(
        data: (data) {
          final receiveData = data;
          log('RankView data: $data');
          log('RankView data receiveData : $receiveData');
          for (var element in receiveData) {
            log('RankView data id: ${element.id}');
            log('RankView data board: ${element.board}');
            log('RankView data thumbnail: ${element.thumbnail}');
            log('RankView data title: ${element.title}');
            log('RankView data content: ${element.content}');
            log('RankView data commentCount: ${element.commentCount}');
            log('RankView data likeCount: ${element.likeCount}');
            log('RankView data createdAt: ${element.createdAt}');
            log('RankView data nickname: ${element.nickname}');
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                for (var i = 0; i < receiveData.length; i++)
                  Column(
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
                          progressIndicatorBuilder: (context, url,
                              downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Assets.images.home.nurbanSymbol.image(),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(ArticleDetailPage.route(
                            board: receiveData[i].board,
                            articleId: receiveData[i].id,
                          ));
                        },
                      ),
                      if(i == 2)
                        Container(
                          width: double.infinity,
                          height: 8,
                          color: colorDivider,
                        ),
                      if(i != 2)
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
