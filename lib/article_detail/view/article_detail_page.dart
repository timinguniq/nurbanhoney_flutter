import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({
    required int articleId,
    super.key
  }): _articleId = articleId;

  final int _articleId;

  static Route route({required int articleId}) {
    return MaterialPageRoute<void>(
      builder: (_) => ArticleDetailPage(
        articleId: articleId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Scaffold(
        body: Container(
          child: Text('Article Detail Page id : $_articleId'),
        ),
      );
    });
  }
}
