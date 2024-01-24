import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';

/// 내 정보 셋팅화면 타이틀
class MyaccountSettingTitleWidget extends StatelessWidget {
  const MyaccountSettingTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return SizedBox(
        width: double.infinity,
        height: 48,
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17),
                  child: SizedBox(
                    width: 16,
                    height: 22,
                    child: Assets.images.articleDetail.backKey.image(),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                  '내 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ),
          ],
        ),
      );
    });
  }
}
