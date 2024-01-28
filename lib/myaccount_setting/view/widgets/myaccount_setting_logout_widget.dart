import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

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
              onTap: () async {
                // TODO: 로그아웃 버튼
                final prefStorageProvider = ref.watch(preferenceStorageProvider);
                final prefStorage = prefStorageProvider.asData?.value;
                await prefStorage?.setEmptyToken();
                // TODO: 상태 unauthorized로 변경
                // TODO: 화면 이동도 어디로 할지 정하기
                ref.watch(authenticationServiceProvider.notifier).set(AuthenticationStatus.unauthenticated);


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
