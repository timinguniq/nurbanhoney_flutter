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

class NurbanView extends StatelessWidget {
  const NurbanView({
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
      final getNurbanAll =
          ref.watch(getNurbanAllProvider((_flag, _articleId, _limit)));
      final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);

      final colorDivider = ref.read(colorEFEFEF);

      return getNurbanAll.when(
        data: (data) {
          final receiveData = data;
          log('getNurbanAll data: $data');
          log('getNurbanAll data receiveData : $receiveData');
          for (var element in receiveData) {
            log('getNurbanAll data id: ${element.id}');
            log('getNurbanAll data board: ${element.board}');
            log('getNurbanAll data thumbnail: ${element.thumbnail}');
            log('getNurbanAll data title: ${element.title}');
            log('getNurbanAll data content: ${element.content}');
            log('getNurbanAll data commentCount: ${element.commentCount}');
            log('getNurbanAll data likeCount: ${element.likeCount}');
            log('getNurbanAll data createdAt: ${element.createdAt}');
            log('getNurbanAll data nickname: ${element.nickname}');
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                for (var element in receiveData)
                  NurbanBoardItemView(
                    badge: const NurbanBoardBadge(),
                    title: element.title,
                    lossCut: element.lossCut,
                    author: element.nickname,
                    date: formattingCreatedAt(element.createdAt),
                    likeCount: element.likeCount,
                    thumbnail: CachedNetworkImage(
                      imageUrl: element.thumbnail ?? '',
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          Assets.images.home.nurbanSymbol.image(),
                    ),
                    onTap: () {
                      Navigator.of(context).push(ArticleDetailPage.route(
                        board: element.board,
                        articleId: element.id,
                      ));
                    },
                  ),
                const AppbarDivider(),
              ],
            ),
          );
        },
        loading: () {
          log('getNurbanAll loading');
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('getNurbanAll error: $error');
          return const Text('error');
        },
      );
    });
  }
}
