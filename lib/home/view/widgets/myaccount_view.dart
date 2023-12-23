import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/board/board.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

class MyaccountView extends StatelessWidget {
  const MyaccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      // TODO: myaccount 통신 바꿔야 됨.
      final prefStorageProvider = ref.watch(preferenceStorageProvider);
      final prefStorage = prefStorageProvider.asData?.value;
      final token = prefStorage?.getToken() ?? '__empty__';

      // TODO : token이 없을 떄 처리 해야 됨.
      final profileProvider = ref.watch(getProfileProvider(token));

      final colorDivider = ref.read(colorEFEFEF);

      return profileProvider.when(
        data: (data) {
          final receiveData = data;

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

          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Text('MyaccountBodyView'),
                ),
                SizedBox(
                  height: 1000,
                ),
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
          return const Text('error');
        },
      );
    });
  }
}
