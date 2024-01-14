import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class MyaccountCommentItemView extends StatelessWidget {
  const MyaccountCommentItemView(
      {required String title, required String data, super.key})
      : _title = title,
        _data = data;

  final String _title;
  final String _data;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final dividerColor = ref.read(colorBBBBBB);

      final titleTextStyle = ref.read(myaccountArticleItemTitleStyle);
      final dataTextStyle = ref.read(myaccountArticleItemDateStyle);

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
                      Text(
                        _data,
                        style: dataTextStyle,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: (){

                    },
                    child: Assets.images.articleDetail.deleteIcon.image(),
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
