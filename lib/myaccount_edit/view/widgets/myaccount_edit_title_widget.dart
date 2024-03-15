import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

import '../myaccount_edit_page.dart';

/// 내 정보 수정화면 타이틀
class MyaccountEditTitleWidget extends StatelessWidget {
  const MyaccountEditTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final titleStyle = ref.read(myaccountEditTitleStyle);
      final confirmStyle = ref.read(myaccountEditConfirmStyle);
      final subTitleStyle = ref.read(myaccountEditSubTitleStyle);
      final subValueStyle = ref.read(myaccountEditSubValueStyle);
      final warnStyle = ref.read(myaccountEditWarnStyle);

      final myaccountEditConfirm = ref.watch(myaccountEditProvider);
      final profileRepository = ref.read(profileRepositoryProvider);

      final preferenceStorage = ref.watch(preferenceStorageProvider);
      final storage = preferenceStorage.asData?.value;
      final token = storage?.getToken() ?? '__empty__';

      final nickname = ref.watch(myaccountEditNicknameNavigationProvider);
      final description = ref.watch(myaccountEditDescriptionNavigationProvider);

      return SizedBox(
        width: double.infinity,
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: InkWell(
                onTap: () async {
                  log('저장 버튼 클릭');
                  log('myaccountEditConfirm : $myaccountEditConfirm');
                  log('insigniaShowList : ${insigniaShowList.toString()}');
                  // 만일 nickname과 description가 빈 스트링이 아니라면 저장
                  if(myaccountEditConfirm){
                    final result = await profileRepository.profileEdit(
                        token: token,
                        nickname: nickname,
                        description: description,
                        insignia: insigniaShowList.toString(),
                    );
                    log('profileEdit result : $result');
                    if(result == 'profile_updated') {
                      Fluttertoast.showToast(
                        msg: '프로필 수정이 완료되었습니다.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      if(context.mounted){
                        Navigator.of(context).pop();
                      }
                    }else{
                      Fluttertoast.showToast(
                        msg: '프로필 수정에 실패했습니다.',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  }else{
                    Fluttertoast.showToast(
                      msg: '닉네임과 자기소개를 입력해주세요.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
