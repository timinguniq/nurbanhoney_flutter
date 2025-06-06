import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// 글 상세 댓글 화면
class ArticleDetailCommentPage extends StatelessWidget {
  const ArticleDetailCommentPage({
    required int articleId,
    super.key,
  }) : _articleId = articleId;

  final int _articleId;

  static Route route({required int articleId}) {
    return MaterialPageRoute<void>(
      builder: (_) => ArticleDetailCommentPage(
        articleId: articleId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final thickDividerColor = ref.read(color55C4C4C4);

      final nurbanArticleComment = ref.watch(getNurbanCommentsProvider(_articleId));

      return nurbanArticleComment.when(
        data: (data) {
          log('ArticleDetailCommentPage data: $data');

          return Column(
            children: [
              if(data.isEmpty)
                const CommentDashboardEmptyWidget()
              else
                CommentDashboardWidget(
                  articleId: _articleId,
                  comments: data,
                ),
              ArticleDetailDivider(
                  thickness: 0.5,
                  color: thickDividerColor,
              ),
              CommentInputWidget(
                articleId: _articleId,
              ),
              ArticleDetailDivider(
                thickness: 0.5,
                color: thickDividerColor,
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
          return Center(
            child: Text('error: $error'),
          );
        },
      );
    });
  }
}
