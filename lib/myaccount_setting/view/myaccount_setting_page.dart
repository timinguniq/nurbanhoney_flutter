import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/myaccount_setting/myaccount_setting.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

/// 내 정보 셋팅화면
class MyaccountSettingPage extends StatelessWidget {
  const MyaccountSettingPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MyaccountSettingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final dividerColor = ref.read(colorBBBBBB);

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
                Expanded(
                  child: Text('test'),
                ),
              ],
            ),
          ),
        ),
      );

    });
  }
}
