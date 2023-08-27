import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

// Consumer widget format
class LikeDislikeBoard extends StatefulWidget {
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
  State<LikeDislikeBoard> createState() => _LikeDislikeBoardState();
}

class _LikeDislikeBoardState extends State<LikeDislikeBoard> {
  late int _likeCount;
  late int _dislikeCount;
  bool _isFirst = true;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);
      final article = ref.watch(getFreeArticleProvider(widget._articleId));

      final articleDetailLikeTextStyle = ref.read(articleDetailLikeStyle);

      final nurbanRepository = ref.read(nurbanRepositoryProvider);

      final preferenceStorage = ref.watch(preferenceStorageProvider);
      final storage = preferenceStorage.asData?.value;
      log('like_dislike_board storage: $storage');

      final token = storage?.getToken() ?? '__empty__';
      log('like_dislike_board token: $token');

      return article.when(
        data: (data) {
          log('like_dislike_board myRating : ${data.myRating}');
          if(_isFirst){
            _likeCount = data.likeCount;
            _dislikeCount = data.dislikeCount;
            _isFirst = false;
          }
          log('like_dislike_board _likeCount: $_likeCount');
          log('like_dislike_board _dislikeCount: $_dislikeCount');
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: Row(
              children: [
                LikeDislikeWidget(
                  onTap: () async {
                    log('like');
                    var result = await nurbanRepository.nurbanLikeCreate(token: token, articleId: widget._articleId);
                    setState(() {
                      _likeCount++;
                      _dislikeCount = data.dislikeCount;
                    });
                  },
                  articleId: widget._articleId,
                  count: _likeCount,
                  icon: Assets.images.home.drawerProfileEdit.image(),
                  title: '좋아요',
                  textStyle: articleDetailLikeTextStyle,
                ),
                const SizedBox(
                  width: 17,
                ),
                LikeDislikeWidget(
                  onTap: () async {
                    log('dislike');
                    var result = await nurbanRepository.nurbanDislikeCreate(token: token, articleId: widget._articleId);
                    setState(() {
                      _likeCount = data.likeCount;
                      _dislikeCount++;
                    });
                  },
                  articleId: widget._articleId,
                  count: _dislikeCount,
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
