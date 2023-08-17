import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class LikeDislikeBoard extends StatelessWidget {
  const LikeDislikeBoard({required int articleId, super.key})
      : _articleId = articleId;

  final int _articleId;

  static Route route({required int articleId}) {
    return MaterialPageRoute<void>(
      builder: (_) => LikeDislikeBoard(
        articleId: articleId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);
      final article = ref.watch(getFreeArticleProvider(_articleId));

      final articleDetailLikeTextStyle = ref.read(articleDetailLikeStyle);

      return article.when(
        data: (data) {
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: Row(
              children: [
                LikeDislikeWidget(
                  onTap: (){
                    log('like');
                  },
                  count: data.likeCount,
                  icon: Assets.images.home.drawerProfileEdit.image(),
                  title: '좋아요',
                  textStyle: articleDetailLikeTextStyle,
                ),
                const SizedBox(
                  width: 17,
                ),
                LikeDislikeWidget(
                  onTap: (){
                    log('dislike');
                  },
                  count: data.dislikeCount,
                  icon: Assets.images.home.drawerProfileEdit.image(),
                  title: '싫어요',
                  textStyle: articleDetailLikeTextStyle,
                ),
              ],
            ),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('LikeDislikeBoard error: $error');
          return const Text('LikeDislikeBoard Error');
        },
      );
    });
  }
}
