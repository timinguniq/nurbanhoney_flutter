import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurbanhoney/home/home.dart';
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
                final prefStorageProvider = ref.watch(preferenceStorageProvider);
                final prefStorage = prefStorageProvider.asData?.value;
                await prefStorage?.setEmptyToken();
                ref.watch(authenticationServiceProvider.notifier).set(AuthenticationStatus.unauthenticated);

                Fluttertoast.showToast(
                  msg: '로그아웃 되었습니다.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  //backgroundColor: ref.read(color000000),
                  //textColor: ref.read(colorFFFFFF),
                  fontSize: 16.0,
                );

                if(context.mounted){
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    Navigator.of(context).pushAndRemoveUntil(
                      HomePage.route(),
                      (route) => false,
                    );
                  });
                }
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
