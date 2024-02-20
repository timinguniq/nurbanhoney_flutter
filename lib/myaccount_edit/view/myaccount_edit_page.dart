import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/myaccount_edit/myaccount_edit.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

var insigniaShowList = <String>[];

/// 내 정보 수정화면
class MyaccountEditPage extends StatefulWidget {
  const MyaccountEditPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MyaccountEditPage(),
    );
  }

  @override
  State<MyaccountEditPage> createState() => _MyaccountEditPageState();
}

class _MyaccountEditPageState extends State<MyaccountEditPage> {
  void _insigniaShowListAdd(String value) {
    setState(() {
      insigniaShowList.add(value);
    });
  }

  void _insigniaShowListRemove(String value) {
    setState(() {
      insigniaShowList.remove(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final dividerColor = ref.read(colorBBBBBB);

      final prefStorageProvider = ref.watch(preferenceStorageProvider);
      final prefStorage = prefStorageProvider.asData?.value;
      final token = prefStorage?.getToken() ?? '__empty__';

      final profileProvider = ref.watch(getProfileProvider(token));

      final titleStyle = ref.read(myaccountEditTitleStyle);
      final confirmStyle = ref.read(myaccountEditConfirmStyle);
      final subTitleStyle = ref.read(myaccountEditSubTitleStyle);
      final subValueStyle = ref.read(myaccountEditSubValueStyle);
      final warnStyle = ref.read(myaccountEditWarnStyle);

      return profileProvider.when(
        data: (data) {
          final receiveData = data;

          log('myaccount insignia show : ${receiveData.insigniaShow}');
          log('myaccount insignia own : ${receiveData.insigniaOwn}');

          insigniaShowList = receiveData.insigniaShow.substring(1, receiveData.insigniaShow.length-1).split(',');

          return Scaffold(
            body: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const MyaccountEditTitleWidget(),
                      ArticleCreateDivider(
                        thickness: 0.5,
                        color: dividerColor,
                      ),
                      MyaccountEditNicknameWidget(
                        nickname: receiveData.nickname,
                      ),
                      ArticleCreateDivider(
                        thickness: 0.5,
                        color: dividerColor,
                      ),
                      MyaccountEditDescriptionWidget(
                        description: receiveData.description == 'null'
                            ? '자기소개를 입력하세요.'
                            : receiveData.description,
                      ),
                      ArticleCreateDivider(
                        thickness: 0.5,
                        color: dividerColor,
                      ),
                      MyaccountEditInsigniaShowWidget(
                        insigniaShowRemove: _insigniaShowListRemove,
                      ),
                      MyaccountEditInsigniaOwnWidget(
                        insigniaOwn: receiveData.insigniaOwn,
                        insigniaShowAdd: _insigniaShowListAdd,
                      ),
                    ],
                  ),
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
