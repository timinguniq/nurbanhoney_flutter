import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';

// myaccount factor view (article, comment, setting)
class MyaccountFactorView extends StatelessWidget {
  const MyaccountFactorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final myaccounttabStatus = ref.watch(myaccountNavigationProvider);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              log('myaccount article clicked');
              ref.read(myaccountNavigationProvider.notifier).select(
                MyaccountTabStatus.article,
              );
            },
            child: SizedBox(
              width: 32,
              height: 32,
              child: myaccounttabStatus == MyaccountTabStatus.article
                  ? Assets.images.myaccount.myaccountArticleActive.image()
                  : Assets.images.myaccount.myaccountArticleInactive.image(),
            ),
          ),
          InkWell(
            onTap: () {
              log('myaccount comment clicked');
              ref.read(myaccountNavigationProvider.notifier).select(
                MyaccountTabStatus.comment,
              );
            },
            child: SizedBox(
              width: 32,
              height: 32,
              child: myaccounttabStatus == MyaccountTabStatus.comment
                  ? Assets.images.myaccount.myaccountCommentActive.image()
                  : Assets.images.myaccount.myaccountCommentInactive.image(),
            ),
          ),
          InkWell(
            onTap: () {
              log('myaccount setting clicked');
            },
            child: SizedBox(
              width: 32,
              height: 32,
              child: Assets.images.myaccount.myaccountSetting.image(),
            ),
          ),
        ],
      );
    });
  }
}
