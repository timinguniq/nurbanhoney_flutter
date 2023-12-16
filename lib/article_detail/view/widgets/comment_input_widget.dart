import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

// Consumer widget format
class CommentInputWidget extends StatelessWidget {
  CommentInputWidget({
    required int articleId,
    super.key,
  }): _articleId = articleId;

  final int _articleId;

  static Route route({
    required int articleId,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => CommentInputWidget(
        articleId: articleId,
      ),
    );
  }

  final fieldText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final inputHintStyle = ref.watch(articleDetailCommentInputHintStyle);
      final registerStyle = ref.watch(articleDetailCommentRegisterStyle);
      final inputStyle = ref.watch(articleDetailCommentInputStyle);
      final colorBorder = ref.watch(colorF6B748);

      final preferenceStorage = ref.watch(preferenceStorageProvider);

      final nurbanRepository = ref.read(nurbanRepositoryProvider);

      var commentText = "";

      return Container(
        width: double.infinity,
        height: 45,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TextField(
                  controller: fieldText,
                  maxLength: 60,
                  onChanged: (text){
                    commentText = text;
                  },
                  decoration: InputDecoration(
                    hintText: '댓글을 입력해주세요.',
                    hintStyle: inputHintStyle,
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  style: inputStyle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 70,
                height: 40,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: BorderSide(
                      color: colorBorder,
                      width: 0.5,
                    ),
                  ),
                  onPressed: () async {
                    log('등록 버튼 클릭');
                    final storage = preferenceStorage.asData?.value;
                    final token = storage?.getToken() ?? '__empty__';

                    log('token: $token');
                    log('articleId: $_articleId');
                    log('commentText: $commentText');

                    if(token == '__empty__') {
                      fieldText.clear();
                      Navigator.of(context).push(
                        LoginPage.route(),
                      );
                      return;
                    } else if(commentText == ""){
                      Fluttertoast.showToast(
                        msg: "빈칸은 입력할 수 없습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0
                      );
                      return;
                    } else{
                      final result = await nurbanRepository.nurbanCommentCreate(
                        token: token,
                        articleId: _articleId,
                        content: commentText,
                      );

                      Future.delayed(const Duration(milliseconds: 500), () {
                        final uuid = ref.read(articleCreateUuidNavigationProvider);

                        ref.watch(nurbanCommentIdProvider.notifier).set(
                          commentId: -1,
                          uuid: uuid,
                        );
                      });
                    }
                  },
                  child: Text(
                    '등록',
                    style: registerStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
