import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

      final nurbanArticleComment = ref.watch(getNurbanCommentsProvider((_articleId, 0, 10)));

      return nurbanArticleComment.when(
        data: (data) {
          log('nurbanArticleComment data: $data');
          if(data.isEmpty){
            log('nurbanArticleComment isEmpty');
          }else {
            log('nurbanArticleComment not isEmpty');
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
              ),
              const SizedBox(
                height: 10,
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
