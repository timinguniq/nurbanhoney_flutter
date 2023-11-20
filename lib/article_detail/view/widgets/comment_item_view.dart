import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

// 댓글 아이템 뷰
class CommentItemView extends StatelessWidget {
  const CommentItemView({
    required String thumbnail,
    required String nickname,
    required String content,
    required bool isAuthor,
    super.key
  }): _thumbnail = thumbnail,
    _nickname = nickname,
    _content = content,
    _isAuthor = isAuthor;

  final String _thumbnail;
  final String _nickname;
  final String _content;
  final bool _isAuthor;

  static Route route({
    required String thumbnail,
    required String nickname,
    required String content,
    required bool isAuthor,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => CommentItemView(
        thumbnail: thumbnail,
        nickname: nickname,
        content: content,
        isAuthor: isAuthor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      //final floatButtonColor = ref.read(colorF6B748);
      //final authenticationProvider = ref.watch(authenticationServiceProvider);
      final commentTextStyle = ref.watch(articleDetailCommentContentStyle);

      return Container(
        width: double.infinity,
        height: 70,
        color: Colors.white,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: _thumbnail,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _nickname,
                    style: commentTextStyle,
                  ),
                  Text(
                    _content,
                    style: commentTextStyle,
                  ),
                ],
              ),
            ),
            if(_isAuthor)
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(_thumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
