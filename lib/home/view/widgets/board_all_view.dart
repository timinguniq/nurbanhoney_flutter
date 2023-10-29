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

class BoardAllView extends StatelessWidget {
  const BoardAllView(
      {required int flag,
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
      final getBoardAll =
          ref.watch(getBoardAllProvider((_flag, _articleId, _limit)));
      final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);

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
                for (var element in receiveData)
                  element.board == 1
                      ? Column(
                          children: [
                            NurbanBoardItemView(
                              title: element.title,
                              lossCut: element.lossCut,
                              author: element.nickname,
                              date: formattingCreatedAt(element.createdAt),
                              likeCount: element.likeCount,
                              thumbnail: CachedNetworkImage(
                                imageUrl: element.thumbnail ?? '',
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    CircularProgressIndicator(value: downloadProgress.progress),
                                errorWidget: (context, url, error) => Assets.images.home.nurbanSymbol.image(),
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .push(ArticleDetailPage.route(
                                  board: element.board,
                                  articleId: element.id,
                                ));
                              },
                            ),
                            const AppbarDivider(),
                          ],
                        )
                      : element.board == 2
                          ? Column(
                              children: [
                                FreeBoardItemView(
                                  title: element.title,
                                  content: element.content,
                                  author: element.nickname,
                                  date: formattingCreatedAt(element.createdAt),
                                  likeCount: element.likeCount,
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(ArticleDetailPage.route(
                                      board: element.board,
                                      articleId: element.id,
                                    ));
                                  },
                                ),
                                const AppbarDivider(),
                              ],
                            )
                          : Column(
                              children: [
                                FreeBoardItemView(
                                  title: element.title,
                                  content: element.content,
                                  author: element.nickname,
                                  date: formattingCreatedAt(element.createdAt),
                                  likeCount: element.likeCount,
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(ArticleDetailPage.route(
                                      board: element.board,
                                      articleId: element.id,
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
