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
      final thumbnail = ref.read(articleCreateThumbnailNavigationProvider);

      // TODO: UI를 Visibiltiy로 감싸고 버튼으로 만들고 이미지 url이 ''이 아니면 이미지 나오게
      return SizedBox(
        height: 43,
        child: Column(
          children: [
            const SizedBox(
              height: 14,
            ),
            Text(
              thumbnail,
              style: lossCutTextStyle,
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
