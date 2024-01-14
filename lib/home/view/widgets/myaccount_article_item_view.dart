import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class MyaccountArticleItemView extends StatelessWidget {
  const MyaccountArticleItemView(
      {required int articleId,
        required int board,
        required String title,
      required String data,
      required String count,
      required String commentCount,
      super.key})
      : _articleId = articleId,
        _board = board,
        _title = title,
        _data = data,
        _count = count,
        _commentCount = commentCount;

  final int _articleId;
  final int _board;
  final String _title;
  final String _data;
  final String _count;
  final String _commentCount;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final dividerColor = ref.read(colorBBBBBB);
      final commentCountBorderColor = ref.read(color808080);

      final titleTextStyle = ref.read(myaccountArticleItemTitleStyle);
      final dataTextStyle = ref.read(myaccountArticleItemDateStyle);
      final commentCountTextStyle =
          ref.read(myaccountArticleItemCommentCountStyle);

      return InkWell(
        onTap: (){
          Navigator.of(context).push(
            ArticleDetailPage.route(
              articleId: _articleId,
              board: _board,
            ),
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: titleTextStyle,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Text(
                              _data,
                              style: dataTextStyle,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              '∙ 조회수 $_count',
                              style: dataTextStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        // border color
                        border: Border.all(
                          width: 1,
                          color: commentCountBorderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _commentCount,
                          style: commentCountTextStyle,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ArticleCreateDivider(
                thickness: 1,
                color: dividerColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}
