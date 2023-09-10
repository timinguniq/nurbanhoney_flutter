import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

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

      final lossCutTextStyle = ref.read(articleCreateLossCutStyle);

      return SizedBox(
        height: 43,
        child: Column(
          children: [
            const SizedBox(
              height: 14,
            ),
            SizedBox(
              height: 22,
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
                  hintText: '₩ 손실액을 입력하세요.',
                  hintStyle: lossCutTextStyle,
                ),
                style: lossCutTextStyle,
                onChanged: (value){
                  ref.read(articleCreateLossCutNavigationProvider.notifier).select(value);
                },
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      );

    });
  }
}
