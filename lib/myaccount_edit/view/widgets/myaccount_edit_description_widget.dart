import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 수정화면 소개
class MyaccountEditDescriptionWidget extends StatelessWidget {
  MyaccountEditDescriptionWidget({
    required String description,
    super.key,
  }): _description = description;

  final String _description;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(myaccountEditTitleStyle);
      final confirmStyle = ref.read(myaccountEditConfirmStyle);
      final subTitleStyle = ref.read(myaccountEditSubTitleStyle);
      final subValueStyle = ref.read(myaccountEditSubValueStyle);
      final warnStyle = ref.read(myaccountEditWarnStyle);

      //String nickname = ref.watch(myaccountEditNicknameNavigationProvider);
      //String description = ref.watch(myaccountEditDescriptionNavigationProvider);

      _controller.text = _description;

      return SizedBox(
          width: double.infinity,
          height: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 21, left: 16),
                child: Text(
                  '소개',
                  style: subTitleStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextField(
                  controller: _controller,
                  maxLength: 100,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '자기소개를 입력하세요.',
                    hintStyle: subValueStyle,
                    counterText: '',
                  ),
                  style: subValueStyle,
                  onChanged: (value){
                    ref.read(myaccountEditDescriptionNavigationProvider.notifier).select(value);
                  },
                ),
              ),
            ],
          )
      );
    });
  }
}
