import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';

// Consumer widget format
// TODO: myaccount article item view를 구현해야됨.
class MyaccountArticleItemView extends StatelessWidget {
  const MyaccountArticleItemView({
    required String title,
    required String data,
    required String count,
    required String commentCount,
    super.key
  }): _title = title,
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

      return SizedBox(
        width: double.infinity,
        height: 75,
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [

                  ],
                ),
                // TODO : commnetCount
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey,
                  ),
                  child: Text(
                    _commentCount,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            ArticleCreateDivider(
              thickness: 1,
              color: Colors.grey,
            ),
          ],
        ),
      );
    });
  }
}
