import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 글 상세 댓글 화면
class ArticleDetailCommentPage extends StatelessWidget {
  const ArticleDetailCommentPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ArticleDetailCommentPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Container();
    });
  }
}
