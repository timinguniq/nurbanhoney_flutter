import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class ArticleCreateAppbar extends StatefulWidget {
  const ArticleCreateAppbar({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ArticleCreateAppbar(),
    );
  }

  @override
  State<ArticleCreateAppbar> createState() => _ArticleCreateAppbarState();
}

class _ArticleCreateAppbarState extends State<ArticleCreateAppbar> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);

      final boardTextStyle = ref.read(articleCreateBoardStyle);
      final confirmTextStyle = ref.read(articleCreateConfirmStyle);

      final boardTitlePickerColor = ref.read(colorF6B748);

      final selectedBoard = ref.watch(articleCreateBoardNavigationProvider);
      final bCreateConfirm = ref.watch(articleCreateProvider);
      return SizedBox(
        height: 48,
        child: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 30,
              height: 30,
              child: Assets.images.articleCreate.articleCreateClose.image(),
            ),
            const Expanded(
              child: SizedBox(
                width: 119,
              )
            ),
            InkWell(
              onTap: () async{
                await _showPickerDialog(
                  context: context,
                  color: boardTitlePickerColor,
                  ref: ref,
                );
              },
              child: Row(
                children: [
                  Text(
                    selectedBoard,
                    style: boardTextStyle,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: Assets.images.articleCreate.articleCreateDowndrop.image(),
                  )
                ],
              ),
            ),
            const Expanded(
                child: SizedBox(
                  width: 84,
                )
            ),
            InkWell(
              onTap: () async{
                log('완료 버튼 클릭');
                log('bCreateConfirm : $bCreateConfirm');
                // TODO: bCreateConfirm가 true이면 글 작성 프로세스
                if(bCreateConfirm){

                }else{
                  // TODO: 부족한 곳을 입력을 해달라는 토스트

                }
              },
              child: Row(
                children: [
                  Text(
                    '완료',
                    style: confirmTextStyle,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                ],
              ),
            ),

          ],
        ),
      );
    });
  }

  Future<void> _showPickerDialog({
    required BuildContext context,
    required Color color,
    required WidgetRef ref,
  }) async{
    showMaterialRadioPicker<StateModel>(
      headerColor: color,
      context: context,
      title: '게시판을 골라주세요.',
      confirmText: '확인',
      cancelText: '취소',
      items: usStates,
      selectedItem: selectedUsState,
      onChanged: (value) => setState(() => selectedUsState = value),
      onConfirmed: () {
        log('게시판 선택 완료 : ${selectedUsState.name}');
        setState((){
          ref.read(articleCreateBoardNavigationProvider.notifier).select(selectedUsState.name);
        });
      },
    );
  }



}

const List<StateModel> usStates = <StateModel>[
  StateModel('너반꿀', 'Nurban'),
  StateModel('자유', 'Free'),
];
StateModel selectedUsState = usStates[0];

//var selectedBoard = '';