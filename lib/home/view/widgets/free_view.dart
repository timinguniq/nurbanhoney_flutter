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

class FreeView extends StatelessWidget {
  const FreeView({
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
      // TODO: 고쳐야 됨.
      final getFreeAll =
      ref.watch(getFreeAllProvider((_flag, _articleId, _limit)));
      final formattingCreatedAt = ref.read(funcFormattingToCreatedAt);

      return getFreeAll.when(
        data: (data) {
          final receiveData = data;
          log('getFreeAll data: $data');
          log('getFreeAll data receiveData : $receiveData');
          for (var element in receiveData) {
            log('getFreeAll data id: ${element.id}');
            log('getFreeAll data board: ${element.board}');
            log('getFreeAll data thumbnail: ${element.thumbnail}');
            log('getFreeAll data title: ${element.title}');
            log('getFreeAll data content: ${element.content}');
            log('getFreeAll data commentCount: ${element.commentCount}');
            log('getFreeAll data likeCount: ${element.likeCount}');
            log('getFreeAll data createdAt: ${element.createdAt}');
            log('getFreeAll data nickname: ${element.nickname}');
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                for (var element in receiveData)
                  Column(
                    children: [
                      FreeBoardItemView(
                        badge: const FreeBoardBadge(),
                        title: element.title,
                        author: element.nickname,
                        content: element.content,
                        date: formattingCreatedAt(element.createdAt),
                        likeCount: element.likeCount,
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
              ],
            ),
          );
        },
        loading: () {
          log('getFreeAll loading');
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('getFreeAll error: $error');
          return const Text('error');
        },
      );
    });
  }
}
