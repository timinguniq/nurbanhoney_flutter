import 'dart:async';
import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

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

      final preferenceStorage = ref.read(preferenceStorageProvider);

      final nurbanRepository = ref.read(nurbanRepositoryProvider);
      final freeRepository = ref.read(freeRepositoryProvider);
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
              flex: 90,
              child: SizedBox(),
            ),
            InkWell(
              onTap: () async {
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
                    child: Assets.images.articleCreate.articleCreateDowndrop
                        .image(),
                  )
                ],
              ),
            ),
            const Expanded(
              flex: 68,
              child: SizedBox(),
            ),
            InkWell(
              onTap: () async {
                log('완료 버튼 클릭');
                log('bCreateConfirm : $bCreateConfirm');
                // TODO: bCreateConfirm가 true이면 글 작성 프로세스
                if (bCreateConfirm) {
                  final board = ref.watch(articleCreateBoardNavigationProvider);
                  final title = ref.watch(articleCreateTitleNavigationProvider);
                  final thumbnail =
                      ref.watch(articleCreateThumbnailNavigationProvider);
                  var lossCut =
                      ref.watch(articleCreateLossCutNavigationProvider);
                  final content =
                      ref.watch(articleCreateContentNavigationProvider);
                  final uuid = ref.read(articleCreateUuidNavigationProvider);

                  final storage = preferenceStorage.asData?.value;
                  final token = storage?.getToken() ?? '__empty__';

                  if (lossCut == '₩ 손실액을 입력하세요.') {
                    lossCut = '0';
                  }

                  String result;
                  log('token: $token');
                  log('board: $board');
                  if (board == '너반꿀') {
                    result = await nurbanRepository.nurbanArticleCreate(
                      token: token,
                      title: title,
                      uuid: uuid,
                      lossCut: int.parse(lossCut),
                      thumbnail: thumbnail,
                      content: content,
                    );
                  } else if (board == '자유') {
                    result = await freeRepository.freeArticleCreate(
                      token: token,
                      title: title,
                      uuid: uuid,
                      content: content,
                    );
                  } else {
                    result = '';
                  }
                  // TODO: 나중에 자유 게시판도 글 작성 되는지 확인

                  log('articleCreateAppbar result : $result');

                  var toastMsg = '';
                  if (result == 'nurbanboard_posted' ||
                      result == 'freeboard_posted') {
                    toastMsg = '글 작성이 되었습니다.';
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } else {
                    toastMsg = '글 작성에 실패했습니다.';
                  }
                  Fluttertoast.showToast(
                      msg: toastMsg,
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  Fluttertoast.showToast(
                      msg: "입력이 안된 부분이 있습니다.",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '완료',
                  style: confirmTextStyle,
                ),
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
  }) async {
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
        setState(() {
          ref
              .read(articleCreateBoardNavigationProvider.notifier)
              .select(selectedUsState.name);
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
