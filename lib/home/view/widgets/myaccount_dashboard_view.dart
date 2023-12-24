import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Myaccount_dashboard
// Thumbnail,, nickanme, description, article count, comment count, point
class MyaccountDashboardView extends StatelessWidget {
  const MyaccountDashboardView({
    required String thumbnail,
    required String nickname,
    required String description,
    required int articleCount,
    required int commentCount,
    required int point,
    super.key,
  }): _thumbnail = thumbnail,
      _nickname = nickname,
      _description = description,
      _articleCount = articleCount,
      _commentCount = commentCount,
      _point = point;

  final String _thumbnail;
  final String _nickname;
  final String _description;
  final int _articleCount;
  final int _commentCount;
  final int _point;

  static Route route({
    required String thumbnail,
    required String nickname,
    required String description,
    required int articleCount,
    required int commentCount,
    required int point,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MyaccountDashboardView(
        thumbnail: thumbnail,
        nickname: nickname,
        description: description,
        articleCount: articleCount,
        commentCount: commentCount,
        point: point,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Column(
        children: [
          Container(
            height: 200,
            color: Colors.red,
          ),
          Container(
            height: 200,
            color: Colors.blue,
          ),
          Container(
            height: 200,
            color: Colors.green,
          ),
          Container(
            height: 200,
            color: Colors.yellow,
          ),
          Container(
            height: 200,
            color: Colors.purple,
          ),
        ],
      );
    });
  }
}
