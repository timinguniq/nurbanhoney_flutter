import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

// 댓글 아이템 뷰
class CommentItemView extends StatelessWidget {
  const CommentItemView(
      {required int articleId,
      required int commentId,
      required String thumbnail,
      required String nickname,
      required String content,
      required bool isAuthor,
      super.key})
      : _articleId = articleId,
        _commentId = commentId,
        _thumbnail = thumbnail,
        _nickname = nickname,
        _content = content,
        _isAuthor = isAuthor;

  final int _articleId;
  final int _commentId;
  final String _thumbnail;
  final String _nickname;
  final String _content;
  final bool _isAuthor;

  static Route route({
    required int articleId,
    required int commentId,
    required String thumbnail,
    required String nickname,
    required String content,
    required bool isAuthor,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => CommentItemView(
        articleId: articleId,
        commentId: commentId,
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
      final commentDeleteTextStyle = ref.watch(articleDetailCommentDeleteStyle);

      //final preferenceStorage = ref.watch(preferenceStorageProvider);

      //final nurbanRepository = ref.watch(nurbanRepositoryProvider);

      return Container(
        width: double.infinity,
        height: 80,
        color: Colors.white,
        child: Row(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: CachedNetworkImage(
                imageUrl: _thumbnail,
                imageBuilder: (context, imageProvider) => Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(top: 12, left: 16, right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    _nickname,
                    style: commentTextStyle,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _content,
                    style: commentTextStyle,
                  ),
                ],
              ),
            ),
            if (_isAuthor)
              InkWell(
                onTap: () async {
                  log("delete icon click");
                  _showDeleteDialog(
                    context: context,
                    textStyle: commentDeleteTextStyle,
                    ref: ref,
                  );
                  /*
                  final storage = preferenceStorage.asData?.value;
                  final token = storage?.getToken() ?? '__empty__';

                  log('token: $token');

                  final result = await nurbanRepository.nurbanCommentDelete(
                    token: token,
                    commentId: _commentId,
                    articleId: _articleId,
                  );

                  log('comment delete result : $result');

                  if(result == 'nurbancomment_deleted'){
                    Future.delayed(const Duration(milliseconds: 500), () {
                      final uuid = ref.read(articleCreateUuidNavigationProvider);

                      ref.watch(nurbanCommentIdProvider.notifier).set(
                        commentId: -1,
                        uuid: uuid,
                      );
                    });
                  }

                   */
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 16),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: 10,
                      height: 20,
                      child: Assets.images.articleDetail.deleteIcon.image(),
                    ),
                  ),
                ),
              ),
            if (!_isAuthor)
              const SizedBox(
                width: 40,
              )
          ],
        ),
      );
    });
  }

  void _showDeleteDialog({
    required BuildContext context,
    required TextStyle textStyle,
    required WidgetRef ref,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: () async {
                log('delete clicked');
                await deleteComment(
                  ref: ref,
                );

                if(context.mounted){
                  Navigator.of(context).pop();
                }
              },
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: Text(
                    '삭제',
                    style: textStyle,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: Text(
                    '취소',
                    style: textStyle,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 13,
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteComment({
    required WidgetRef ref,
  }) async {
    final preferenceStorage = ref.watch(preferenceStorageProvider);

    final nurbanRepository = ref.watch(nurbanRepositoryProvider);

    final storage = preferenceStorage.asData?.value;
    final token = storage?.getToken() ?? '__empty__';

    log('token: $token');

    final result = await nurbanRepository.nurbanCommentDelete(
      token: token,
      commentId: _commentId,
      articleId: _articleId,
    );

    log('comment delete result : $result');

    if (result == 'nurbancomment_deleted') {
      Future.delayed(const Duration(milliseconds: 500), () {
        final uuid = ref.read(articleCreateUuidNavigationProvider);

        ref.watch(nurbanCommentIdProvider.notifier).set(
              commentId: -1,
              uuid: uuid,
            );
      });
    }
  }
}
