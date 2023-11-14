import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class CommentDashboardEmptyWidget extends StatelessWidget {
  const CommentDashboardEmptyWidget({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CommentDashboardEmptyWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {

      final commentEmptyTextStyle = ref.watch(articleDetailCommentEmptyStyle);
      return Container(
        width: double.infinity,
        height: 280,
        color: Colors.white,
        child: Center(
          child: Text(
            textAlign: TextAlign.center,
            '댓글이 없습니다.\n첫 댓글을 작성 해 보세요.',
            style: commentEmptyTextStyle,
          ),
        )
      );
    });
  }
}
