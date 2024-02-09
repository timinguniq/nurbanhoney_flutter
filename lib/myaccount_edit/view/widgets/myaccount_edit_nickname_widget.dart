import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 수정화면 닉네임
class MyaccountEditNicknameWidget extends StatelessWidget {
  const MyaccountEditNicknameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(myaccountEditTitleStyle);
      final confirmStyle = ref.read(myaccountEditConfirmStyle);
      final subTitleStyle = ref.read(myaccountEditSubTitleStyle);
      final subValueStyle = ref.read(myaccountEditSubValueStyle);
      final warnStyle = ref.read(myaccountEditWarnStyle);

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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Assets.images.myaccount.myaccountEditCancel.image(),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '프로필 수정',
                style: titleStyle,
              ),
            ),
            InkWell(
              onTap: (){
                log('저장 버튼 클릭');
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '저장',
                    style: confirmStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
