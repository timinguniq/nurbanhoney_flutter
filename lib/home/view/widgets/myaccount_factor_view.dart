import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';

// myaccount factor view (article, comment, setting)
class MyaccountFactorView extends StatelessWidget {
  const MyaccountFactorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              log('myaccount article clicked');
            },
            child: SizedBox(
              width: 32,
              height: 32,
              child: Assets.images.myaccount.myaccountArticleInactive.image(),
            ),
          ),
          InkWell(
            onTap: () {
              log('myaccount comment clicked');
            },
            child: SizedBox(
              width: 32,
              height: 32,
              child: Assets.images.myaccount.myaccountCommentInactive.image(),
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
