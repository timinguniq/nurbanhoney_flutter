import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';

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

      final selectedContent = ref.watch(articleCreateContentNavigationProvider);

      return Container(
        height: 60,
        child: Text(selectedContent),
      );
    });
  }
}
