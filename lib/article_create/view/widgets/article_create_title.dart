import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class ArticleCreateTitle extends StatelessWidget {
  const ArticleCreateTitle({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ArticleCreateTitle(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final titleTextStyle = ref.read(articleCreateTitleStyle);

      return SizedBox(
        height: 53,
        child: Column(
          children: [
            const SizedBox(
              height: 17,
            ),
            SizedBox(
              height: 22,
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                  hintText: '제목을 입력하세요.',
                  hintStyle: titleTextStyle,
                ),
                style: titleTextStyle,
                onChanged: (value){
                  ref.read(articleCreateTitleNavigationProvider.notifier).select(value);
                },
              ),
            ),
            const SizedBox(
              height: 14,
            ),
          ],
        ),
      );
    });
  }
}
