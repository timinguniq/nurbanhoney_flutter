import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 셋팅화면 로그아웃
class MyaccountSettingLogoutWidget extends StatelessWidget {
  const MyaccountSettingLogoutWidget({
    required String type,
    super.key,
  }) : _type = type;

  final String _type;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final typeStyle = ref.read(myaccountSettingTypeStyle);
      final logoutStyle = ref.read(myaccountSettingLogoutStyle);

      return SizedBox(
        width: double.infinity,
        height: 53,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text(
                _type,
                style: typeStyle,
              ),
            ),
            InkWell(
              onTap: () {
                // TODO: 로그아웃 버튼
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '로그아웃',
                  style: logoutStyle,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
