import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        height: 90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '닉네임',
              style: subTitleStyle,
            ),
            TextField(
              style: subValueStyle,
              decoration: InputDecoration(
                hintText: '닉네임을 입력해주세요',
                hintStyle: subValueStyle,
              ),
            ),
          ],
        )
      );
    });
  }
}
