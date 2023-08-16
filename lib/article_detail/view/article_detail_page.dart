import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:share_service/share_service.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage(
      {required int board, required int articleId, super.key})
      : _board = board,
        _articleId = articleId;

  final int _board;
  final int _articleId;

  static Route route({
    required int articleId,
    required int board,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => ArticleDetailPage(
        articleId: articleId,
        board: board,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);
      final thinDividerColor = ref.read(color55000000);
      final thickDividerColor = ref.read(color55C4C4C4);

      final appBarTitleStyle = ref.read(articleDetailAppbarTitleStyle);

      return Scaffold(
        appBar: ArticleDetailAppBar(
          board: _board,
          appBarTitleStyle: appBarTitleStyle,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ArticleDetailDivider(
                thickness: 0.5,
                color: thinDividerColor,
              ),
              // TitleBoard
              _board == 1
                  ? NurbanTitleBoard(
                      articleId: _articleId,
                    )
                  : _board == 2
                      ? FreeTitleBoard(
                          articleId: _articleId,
                        )
                      : FreeTitleBoard(
                          articleId: _articleId,
                        ),
              ArticleDetailDivider(
                thickness: 0.5,
                color: thinDividerColor,
              ),
              // Content
              _board == 1
                  ? NurbanContentBoard(
                      articleId: _articleId,
                    )
                  : _board == 2
                      ? FreeContentBoard(
                          articleId: _articleId,
                        )
                      : FreeContentBoard(
                          articleId: _articleId,
                        ),
              ArticleDetailDivider(
                thickness: 0.5,
                color: thinDividerColor,
              ),
              LikeDislikeBoard(
                articleId: _articleId,
              ),
              ArticleDetailDivider(
                thickness: 8,
                color: thickDividerColor,
              ),
            ],
          ),
        ),
      );
    });
  }
}
