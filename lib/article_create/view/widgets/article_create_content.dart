import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class ArticleCreateContent extends StatelessWidget {
  const ArticleCreateContent({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ArticleCreateContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final contentTextStyle = ref.read(articleCreateContentStyle);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: TextField(
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            hintText: '내용을 입력하세요.',
            hintStyle: contentTextStyle,
          ),
          style: contentTextStyle,
          onChanged: (value) {
            ref
                .read(articleCreateContentNavigationProvider.notifier)
                .select(value);
          },
        ),
      );
    });
  }
}
