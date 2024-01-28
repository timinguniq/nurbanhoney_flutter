import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 내 정보 셋팅화면 탈퇴하기
class MyaccountSettingWithdrawalWidget extends StatelessWidget {
  const MyaccountSettingWithdrawalWidget({
    required int userId,
    super.key
  }): _userId = userId;

  final int _userId;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final withdrawalStyle = ref.read(myaccountSettingWithdrawalStyle);

      final profileRepository = ref.read(profileRepositoryProvider);

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
              onTap: () async {
                //Navigator.of(context).pop();
                log('탈퇴하기');
                final prefStorageProvider = ref.watch(preferenceStorageProvider);
                final prefStorage = prefStorageProvider.asData?.value;
                final token = prefStorage?.getToken() ?? '__empty__';

                final result = await profileRepository.myaccountWithdrawal(
                  token: token,
                  userId: _userId,
                );
                log('탈퇴하기 result: $result');
                if(result == 'profile_withdrawal'){
                  Fluttertoast.showToast(
                    msg: '탈퇴 되었습니다.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0,
                  );

                  // 탈퇴 성공
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    Navigator.of(context).pushAndRemoveUntil(
                      HomePage.route(),
                      (route) => false,
                    );
                  });
                }else{
                  // 탈퇴 실패
                }
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
