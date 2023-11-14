import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// Consumer widget format
class CommentInputWidget extends StatelessWidget {
  const CommentInputWidget({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const CommentInputWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final inputHintStyle = ref.watch(articleDetailCommentInputHintStyle);
      final registerStyle = ref.watch(articleDetailCommentRegisterStyle);
      final inputStyle = ref.watch(articleDetailCommentInputStyle);
      final colorBorder = ref.watch(colorF6B748);
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
                  decoration: InputDecoration(
                    hintText: '댓글을 입력해주세요.',
                    hintStyle: inputHintStyle,
                    border: InputBorder.none,
                  ),
                  style: inputStyle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
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
                onPressed: () {},
                child: Text(
                  '등록',
                  style: registerStyle,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
