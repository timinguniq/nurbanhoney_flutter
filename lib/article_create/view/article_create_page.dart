import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class ArticleCreatePage extends StatelessWidget {
  const ArticleCreatePage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ArticleCreatePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final boardTextStyle = ref.read(articleCreateBoardStyle);
      final confirmTextStyle = ref.read(articleCreateConfirmStyle);
      final titleTextStyle = ref.read(articleCreateTitleStyle);
      final lossCutTextStyle = ref.read(articleCreateLossCutStyle);
      final contentTextStyle = ref.read(articleCreateContentStyle);

      return Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Container(
            child: Text('ArticleCreatePage'),
          ),
        ),
      );
    });
  }
}
