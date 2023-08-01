import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({required int articleId, super.key})
      : _articleId = articleId;

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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: AppBar(
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
                    child: Text('article_detail',
                        style: TextStyle(color: Colors.black)),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Container(
          child: Text('Article Detail Page id : $_articleId'),
        ),
      );
    });
  }
}
