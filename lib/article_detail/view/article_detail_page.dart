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
            ],
          ),
        ),
      );
    });
  }
}

// 너반꿀 디테일 보드(썸네일 컨텐츠)
class NurbanContentBoard extends StatelessWidget {
  const NurbanContentBoard({required int articleId, Key? key})
      : _articleId = articleId,
        super(key: key);

  final int _articleId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final nurbanArticle = ref.watch(getNurbanArticleProvider(_articleId));

      // TextStyle
      final articleDetailNurbanContentTextStyle =
          ref.read(articleDetailNurbanContentStyle);

      return nurbanArticle.when(
        data: (data) {
          log('NurbanContentBoard data: $data');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Image.network(
                  data.thumbnail,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 17),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.content,
                    style: articleDetailNurbanContentTextStyle,
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('NurbanContentBoard error: $error');
          return const Text('NurbanContentBoard Error');
        },
      );
    });
  }
}

// 자유게시판 디테일 보드(컨텐츠)
class FreeContentBoard extends StatelessWidget {
  const FreeContentBoard({required int articleId, Key? key})
      : _articleId = articleId,
        super(key: key);

  final int _articleId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final nurbanArticle = ref.watch(getNurbanArticleProvider(_articleId));

      // TextStyle
      final articleDetailNurbanContentTextStyle =
          ref.read(articleDetailNurbanContentStyle);

      return nurbanArticle.when(
        data: (data) {
          log('FreeContentBoard data: $data');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 17),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.content,
                    style: articleDetailNurbanContentTextStyle,
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('FreeContentBoard error: $error');
          return const Text('FreeContentBoard Error');
        },
      );
    });
  }
}
