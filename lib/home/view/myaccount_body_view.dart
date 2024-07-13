import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class MyaccountBodyView extends ConsumerWidget {
  const MyaccountBodyView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefStorageProvider = ref.watch(preferenceStorageProvider);
    final prefStorage = prefStorageProvider.asData?.value;
    final token = prefStorage?.getToken() ?? '__empty__';

    final profileProvider = ref.watch(getProfileProvider(token));

    return profileProvider.when(
      data: (data) {
        final receiveData = data;
        final myUserId = receiveData.id;
        log('MyaccountBodyView myUserId: $myUserId');

        return Column(
          children: [
            const AppbarDivider(),
            Expanded(
              child: MyaccountView(
                userId: myUserId,
              ),
            ),
          ],
        );
      },
      loading: () {
        log('MyaccountBodyView loading');
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stackTrace) {
        log('MyaccountBodyView error: $error');

        /// Token 없을 때 처리
        if (token == '__empty__') {
          Future.delayed(const Duration(milliseconds: 100), () {
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
  }

}
