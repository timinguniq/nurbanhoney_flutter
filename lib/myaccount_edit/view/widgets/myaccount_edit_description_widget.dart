import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 수정화면 닉네임
class MyaccountEditNicknameWidget extends StatelessWidget {
  MyaccountEditNicknameWidget({
    required String nickname,
    super.key,
  }): _nickname = nickname;

  final String _nickname;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(myaccountEditTitleStyle);
      final confirmStyle = ref.read(myaccountEditConfirmStyle);
      final subTitleStyle = ref.read(myaccountEditSubTitleStyle);
      final subValueStyle = ref.read(myaccountEditSubValueStyle);
      final warnStyle = ref.read(myaccountEditWarnStyle);

      _controller.text = _nickname;

      return SizedBox(
          width: double.infinity,
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 16),
                child: Text(
                  '닉네임',
                  style: subTitleStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '닉네임을 입력하세요.',
                    hintStyle: subValueStyle,
                  ),
                  style: subValueStyle,
                  onChanged: (value){
                    ref.read(myaccountEditNicknameNavigationProvider.notifier).select(value);
                  },
                ),
              ),
            ],
          )
      );
    });
  }
}
