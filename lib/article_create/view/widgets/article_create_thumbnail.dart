import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class ArticleCreateThumbnail extends StatelessWidget {
  const ArticleCreateThumbnail({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ArticleCreateThumbnail(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final lossCutTextStyle = ref.read(articleCreateLossCutStyle);
      // TODO(Cross): 여기 해야됨.
      final thumbnail = ref.read(articleCreateThumbnailNavigationProvider.notifier).select(value);

      return SizedBox(
        height: 43,
        child: Column(
          children: [
            const SizedBox(
              height: 14,
            ),
            SizedBox(
              height: 17,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  hintText: '썸네일 입력 해야됨.',
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
