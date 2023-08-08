import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

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

      final appBarTitleStyle = ref.read(articleDetailTitleStyle);

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
                      board: _board,
                      articleId: _articleId,
                    )
                  : _board == 2
                      ? FreeTitleBoard(
                          board: _board,
                          articleId: _articleId,
                        )
                      : FreeTitleBoard(
                          board: _board,
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

class ArticleDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ArticleDetailAppBar({
    required int board,
    required TextStyle appBarTitleStyle,
    super.key,
  }) : _board = board,
       _appBarTitleStyle = appBarTitleStyle;

  final int _board;
  final TextStyle _appBarTitleStyle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 0,
      title: SizedBox(
        width: double.infinity,
        height: 48,
        child: Stack(
          children: [
            // back key icon
            SizedBox(
              width: 42,
              height: 48,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: _board == 1
                  ? Text(
                      '너반꿀',
                      style: _appBarTitleStyle,
                    )
                  : _board == 2
                      ? Text(
                          '자유게시판',
                          style: _appBarTitleStyle,
                        )
                      : Text(
                          '자유게시판',
                          style: _appBarTitleStyle,
                        ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

// 너반꿀 디테일 보드(제목, 작가, 작성일, 손실액)
class NurbanTitleBoard extends StatelessWidget {
  const NurbanTitleBoard({
    required int board,
    required int articleId,
    Key? key
  }): _board = board,
      _articleId = articleId,
      super(key: key);

  final int _board;
  final int _articleId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {

      final nurbanArticle = ref.watch(getNurbanArticleProvider(_articleId));
      return nurbanArticle.when(
        data: (data) {
          log('nurbanArticle data: $data');
          return Container(
            child: Text('NurbanTitleBoard'),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('nurbanArticle error: $error');
          return Container(
            child: Text('NurbanTitleBoard Error'),
          );
        },
      );
    });
  }
}

// 자유게시판 디테일 보드(제목, 작가, 작성일)
class FreeTitleBoard extends StatelessWidget {
  const FreeTitleBoard({
    required int board,
    required int articleId,
    Key? key
  }): _board = board,
      _articleId = articleId,
        super(key: key);

  final int _board;
  final int _articleId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final freeArticle = ref.watch(getFreeArticleProvider(_articleId));

      return freeArticle.when(
        data: (data) {
          log('freeArticle data: $data');
          return Container(
            child: Text('FreeTitleBoard'),
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('freeArticle error: $error');
          return Container(
            child: Text('FreeTitleBoard Error'),
          );
        },
      );
    });
  }
}
