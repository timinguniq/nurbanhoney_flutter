import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
// TODO: myaccount article item view를 구현해야됨.
class MyaccountArticleItemView extends StatelessWidget {
  const MyaccountArticleItemView(
      {required String title,
      required String data,
      required String count,
      required String commentCount,
      super.key})
      : _title = title,
        _data = data,
        _count = count,
        _commentCount = commentCount;

  final String _title;
  final String _data;
  final String _count;
  final String _commentCount;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final dividerColor = ref.read(colorBBBBBB);
      final commentCountBorderColor = ref.read(color808080);

      final titleTextStyle = ref.read(myaccountArticleItemTitleStyle);
      final dataTextStyle = ref.read(myaccountArticleItemDateStyle);
      final commentCountTextStyle =
          ref.read(myaccountArticleItemCommentCountStyle);

      return Column(
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
      );
    });
  }
}
