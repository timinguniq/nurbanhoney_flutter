import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 셋팅화면 탈퇴하기
class MyaccountSettingWithdrawalWidget extends StatelessWidget {
  const MyaccountSettingWithdrawalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final withdrawalStyle = ref.read(myaccountSettingWithdrawalStyle);

      return SizedBox(
        width: double.infinity,
        height: 53,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text(
                '탈퇴하기',
                style: withdrawalStyle,
              ),
            ),
            InkWell(
              onTap: () {
                //Navigator.of(context).pop();
                log('탈퇴하기');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 22,
                  height: 33,
                  child: Assets.images.articleDetail.backKey.image(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
