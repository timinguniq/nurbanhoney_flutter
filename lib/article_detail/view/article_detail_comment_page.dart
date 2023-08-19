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

      // TODO: comment data 통신 구현해서 데이터 받아야됨.

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
    });
  }
}
