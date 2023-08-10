import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
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
  })  : _board = board,
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
  const NurbanTitleBoard({required int board, required int articleId, Key? key})
      : _board = board,
        _articleId = articleId,
        super(key: key);

  final int _board;
  final int _articleId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final nurbanArticle = ref.watch(getNurbanArticleProvider(_articleId));

      // TextStyle
      final articleDetailNurbanTitleTextStyle =
          ref.read(articleDetailNurbanTitleStyle);
      final articleDetailNurbanAuthorTextStyle =
          ref.read(articleDetailNurbanAuthorStyle);
      final articleDetailNurbanElementTextStyle =
          ref.read(articleDetailNurbanElementStyle);
      final articleDetailNurbanLossCutTitleTextStyle =
          ref.read(articleDetailNurbanLossCutTitleStyle);
      final articleDetailNurbanLossCutValueTextStyle =
          ref.read(articleDetailNurbanLossCutValueStyle);

      return nurbanArticle.when(
        data: (data) {
          log('nurbanArticle data: $data');
          log('nurbanArticle insignia: ${data.insignia}');
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  data.title,
                  style: articleDetailNurbanTitleTextStyle,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                height: 21,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    Image.network(
                      data.badge,
                      width: 21,
                      height: 21,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      data.nickname,
                      style: articleDetailNurbanAuthorTextStyle,
                    ),
                    const SizedBox(
                      width: 16,
                    ),

                    /// TODO: 휘장 리스트 작성.

                  ],
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  SizedBox(
                    height: 16,
                    child: Text(
                      data.updatedAt.toString(),
                      style: articleDetailNurbanElementTextStyle,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      '조회수',
                      style: articleDetailNurbanElementTextStyle,
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  SizedBox(
                    height: 16,
                    child: Text(
                      data.count.toString(),
                      style: articleDetailNurbanElementTextStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      '손실액',
                      style: articleDetailNurbanLossCutTitleTextStyle,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: Assets.images.articleDetail.lossCutIcon.image(),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      data.lossCut.toString(),
                      style: articleDetailNurbanLossCutValueTextStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
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
  const FreeTitleBoard({required int board, required int articleId, Key? key})
      : _board = board,
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
