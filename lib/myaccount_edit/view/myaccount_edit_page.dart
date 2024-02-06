import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/myaccount_setting/myaccount_setting.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 내 정보 수정화면
class MyaccountEditPage extends StatelessWidget {
  const MyaccountEditPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MyaccountEditPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final dividerColor = ref.read(colorBBBBBB);

      final prefStorageProvider = ref.watch(preferenceStorageProvider);
      final prefStorage = prefStorageProvider.asData?.value;
      final token = prefStorage?.getToken() ?? '__empty__';

      final profileProvider = ref.watch(getProfileProvider(token));

      return profileProvider.when(
        data: (data) {
          final receiveData = data;

          return Scaffold(
            body: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    const MyaccountSettingTitleWidget(),
                    ArticleCreateDivider(
                      thickness: 0.5,
                      color: dividerColor,
                    ),
                    MyaccountSettingLogoutWidget(
                      type: receiveData.loginType,
                    ),
                    ArticleCreateDivider(
                      thickness: 0.5,
                      color: dividerColor,
                    ),
                    MyaccountSettingWithdrawalWidget(
                      userId: receiveData.id,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () {
          log('myaccount edit loading');
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          log('myaccount edit error: $error');
          return const Text('error');
        },
      );

    });
  }
}
