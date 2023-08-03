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


      return Scaffold(
        appBar: ArticleDetailAppBar(
          board: _board,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
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
    super.key,
  }) : _board = board;

  final int _board;

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
                  ? const Text(
                      '너반꿀',
                      style: TextStyle(color: Colors.black),
                    )
                  : _board == 2
                      ? const Text(
                          '자유게시판',
                          style: TextStyle(color: Colors.black),
                        )
                      : const Text(
                          '자유게시판',
                          style: TextStyle(color: Colors.black),
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
