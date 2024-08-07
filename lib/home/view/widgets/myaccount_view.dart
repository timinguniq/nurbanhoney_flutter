import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/board/board.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney/myaccount_edit/myaccount_edit.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

/// {myaccount_view}
class MyaccountView extends StatelessWidget {
  MyaccountView({
    super.key,
    required this.userId,
  });

  final int userId;
  var isMine = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final prefStorageProvider = ref.watch(preferenceStorageProvider);
      final prefStorage = prefStorageProvider.asData?.value;
      final token = prefStorage?.getToken() ?? '__empty__';

      final profileProvider = ref.watch(getProfileProvider(token));

      // text style
      final reviseStyle = ref.read(myaccountReviseStyle);
      final nicknameStyle = ref.read(myaccountNicknameStyle);
      final introduceStyle = ref.read(myaccountIntroduceStyle);
      final factorTitleStyle = ref.read(myaccountFactorTitleStyle);
      final factorValueStyle = ref.read(myaccountFactorValueStyle);
      final articleTitleStyle = ref.read(myaccountArticleTitleStyle);
      final articleDateStyle = ref.read(myaccountArticleDateStyle);
      final articleCountStyle = ref.read(myaccountArticleCountStyle);

      // color
      final reviseButtonColor = ref.read(colorF6B748);
      final factorBorderColor = ref.read(colorEDEDED);
      final dashboardBorderColor = ref.read(colorBBBBBB);

      return profileProvider.when(
        data: (data) {
          final receiveData = data;
          final myUserId = receiveData.id;
          isMine = myUserId == userId;

          log('myaccount_view isMine : $isMine');
          log('myaccount_view whole : $receiveData');
          log('myaccount_view id: ${receiveData.id}');
          log('myaccount_view loginType: ${receiveData.loginType}');
          log('myaccount_view badge: ${receiveData.badge}');
          log('myaccount_view nickname: ${receiveData.nickname}');
          log('myaccount_view description: ${receiveData.description}');
          log('myaccount_view point: ${receiveData.point}');
          log('myaccount_view insigniaShow: ${receiveData.insigniaShow}');
          log('myaccount_view insigniaOwn: ${receiveData.insigniaOwn}');
          log('myaccount_view myArticleCount: ${receiveData.myArticleCount}');
          log('myaccount_view myCommentCount: ${receiveData.myCommentCount}');

          final myaccounttabStatus = ref.watch(myaccountNavigationProvider);

          return SingleChildScrollView(
            child: Column(
              children: [
                // 수정 버튼
                Align(
                  alignment: Alignment.centerRight,
                  child:  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 16),
                    child: SizedBox(
                      width: 57,
                      height: 30,
                      child: ElevatedButton(
                          onPressed: () {
                            log('myaccount_view 수정 버튼 클릭');
                            Navigator.of(context).push(
                              MyaccountEditPage.route(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: reviseButtonColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            '수정',
                            style: reviseStyle,
                          ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 33,
                ),
                // 대시보드
                MyaccountDashboardView(
                  thumbnail: receiveData.badge,
                  nickname: receiveData.nickname,
                  insigniaShow: receiveData.insigniaShow,
                  description: receiveData.description,
                  articleCount: receiveData.myArticleCount,
                  commentCount: receiveData.myCommentCount,
                  point: receiveData.point,
                ),
                //
                const SizedBox(
                  height: 26,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ArticleCreateDivider(
                    thickness: 0.5,
                    color: dashboardBorderColor,
                  ),
                ),
                const SizedBox(
                  height: 11,
                ),
                // 팩터
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 55),
                  child: MyaccountFactorView(),
                ),
                const SizedBox(
                  height: 10,
                ),
                ArticleCreateDivider(
                    thickness: 12,
                    color: factorBorderColor,
                ),
                if(myaccounttabStatus == MyaccountTabStatus.article)
                  const MyaccountTabArticleView(),
                if(myaccounttabStatus == MyaccountTabStatus.comment)
                  const MyaccountTabCommentView(),
              ],
            ),
          );
        },
        loading: () {
          log('myaccount_view loading');
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('myaccount_view error: $error');
          /// Token 없을 때 처리
          if(token == '__empty__') {
            Future.delayed(const Duration(milliseconds: 100),(){
              Navigator.of(context).push(
                LoginPage.route(),
              );
            });

            return const Center(
              child: Text('로그인이 필요합니다.'),
            );
          }
          //
          return const Text('error');
        },
      );
    });
  }
}
