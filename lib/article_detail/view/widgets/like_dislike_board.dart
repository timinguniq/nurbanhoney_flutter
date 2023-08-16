import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                const SizedBox(
                  width: 16,
                ),
                // TODO: 좋아요 이미지 넣어야됨.
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Container(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '좋아요',
                  style: articleDetailLikeTextStyle,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  data.likeCount.toString(),
                  style: articleDetailLikeTextStyle,
                ),
                const SizedBox(
                  width: 17,
                ),
                // TODO: 싫어요 이미지 넣어야됨.
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Container(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '싫어요',
                  style: articleDetailLikeTextStyle,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  data.dislikeCount.toString(),
                  style: articleDetailLikeTextStyle,
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
