import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
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

      final boundaryColor = ref.read(color55000000);

      final selectedBoard = ref.watch(articleCreateBoardNavigationProvider);

      return Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ArticleCreateAppbar(),
                ArticleCreateDivider(
                  thickness: 0.5,
                  color: boundaryColor,
                ),
                const ArticleCreateTitle(),
                ArticleCreateDivider(
                  thickness: 0.5,
                  color: boundaryColor,
                ),
                const ArticleCreateThumbnail(),
                ArticleCreateDivider(
                  thickness: 0.5,
                  color: boundaryColor,
                ),
                const ArticleCreateLossCut(),
                ArticleCreateDivider(
                  thickness: 0.5,
                  color: boundaryColor,
                ),
                const ArticleCreateContent(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
