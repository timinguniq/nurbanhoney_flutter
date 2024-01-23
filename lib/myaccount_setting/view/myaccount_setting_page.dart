import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/myaccount_setting/myaccount_setting.dart';

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

      return Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                MyaccountSettingTitleWidget(),
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
