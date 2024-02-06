import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 수정화면 타이틀
class MyaccountEditTitleWidget extends StatelessWidget {
  const MyaccountEditTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(myaccountSettingTitleStyle);
      final typeStyle = ref.read(myaccountSettingTypeStyle);
      final logoutStyle = ref.read(myaccountSettingLogoutStyle);
      final withdrawalStyle = ref.read(myaccountSettingWithdrawalStyle);

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
                  padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 0),
                  child: SizedBox(
                    width: 22,
                    height: 33,
                    child: Assets.images.articleDetail.backKey.image(),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '내 정보',
                style: titleStyle,
              ),
            ),
          ],
        ),
      );
    });
  }
}
