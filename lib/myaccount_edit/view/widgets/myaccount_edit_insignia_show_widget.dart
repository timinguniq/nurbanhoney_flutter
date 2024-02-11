import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 수정화면 보이는 휘장
class MyaccountEditInsigniaShowWidget extends StatelessWidget {
  MyaccountEditInsigniaShowWidget({
    required String insigniaShow,
    super.key,
  }): _insigniaShow = insigniaShow;

  final String _insigniaShow;

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
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 16),
                child: Text(
                  '보이는 휘장',
                  style: subTitleStyle,
                ),
              ),

            ],
          )
      );
    });
  }
}
