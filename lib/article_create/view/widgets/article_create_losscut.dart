import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';

// Consumer widget format
class ArticleCreateLossCut extends StatelessWidget {
  const ArticleCreateLossCut({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ArticleCreateLossCut(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final selectedLossCut = ref.watch(articleCreateLossCutNavigationProvider);

      return Container(
        height: 60,
        child: Text(selectedLossCut),
      );
    });
  }
}
