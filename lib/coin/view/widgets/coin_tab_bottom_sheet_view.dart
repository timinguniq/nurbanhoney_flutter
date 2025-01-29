import 'dart:developer';

import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class CoinTabBottomSheetView extends StatelessWidget {
  const CoinTabBottomSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final borderColor = ref.read(colorC9C9C9);
      final textStyle = ref.read(articleCreateStyle);

      final authenticationProvider = ref.watch(authenticationServiceProvider);

      return InkWell(
        onTap: () {
          if (authenticationProvider ==
              AuthenticationStatus.authenticated) {
            Navigator.of(context).push(ArticleCreatePage.route());
          } else {
            Navigator.of(context).push(LoginPage.route());
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '내의견 등록하기',
                style: textStyle,
              ),
            ),
          ),
        ),
      );
    });
  }
}
