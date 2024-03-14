import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/myaccount_edit/myaccount_edit.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

var insigniaShowList = <String>{};
var isFirst = true;

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
  @override
  void initState() {
    super.initState();
    insigniaShowList.clear();
    isFirst = true;
  }

  void _insigniaShowListAdd(String value) {
    setState(() {
      insigniaShowList.add(value.trim());
    });
  }

  void _insigniaShowListRemove(String value) {
    setState(() {
      insigniaShowList.remove(value.trim());
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

      String nickname = "";
      String description = "";

      return profileProvider.when(
        data: (data) {
          // TODO: 아직도 뭔가 이상한데 수정해야 됨.(휘장 이미지가 안나옴)
          final receiveData = data;

          log('myaccount insignia show : ${receiveData.insigniaShow}');
          log('myaccount insignia own : ${receiveData.insigniaOwn}');

          if(insigniaShowList.isEmpty && isFirst){
            insigniaShowList.clear();
            insigniaShowList = receiveData.insigniaShow.substring(1, receiveData.insigniaShow.length-1)
                .split(',')
                .map((e) => e.trim())
                .toSet();

            Future.delayed(const Duration(milliseconds: 500), () {
              ref.read(myaccountEditNicknameNavigationProvider.notifier).select(receiveData.nickname);
              ref.read(myaccountEditDescriptionNavigationProvider.notifier).select(receiveData.description);
            });

            nickname = receiveData.nickname;
            description = receiveData.description;

            log('insigniaShowList 1 : $insigniaShowList');
            isFirst = false;
          }else{
            nickname = ref.read(myaccountEditNicknameNavigationProvider);
            description = ref.read(myaccountEditDescriptionNavigationProvider);
          }
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
                        nickname: nickname,
                      ),
                      ArticleCreateDivider(
                        thickness: 0.5,
                        color: dividerColor,
                      ),
                      MyaccountEditDescriptionWidget(
                        description: receiveData.description == 'null'
                            ? '자기소개를 입력하세요.'
                            : description,
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
