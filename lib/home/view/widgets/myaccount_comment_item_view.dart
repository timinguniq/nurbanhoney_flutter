import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class MyaccountCommentItemView extends StatelessWidget {
  const MyaccountCommentItemView(
      {required int id,
        required int articleId,
        required String title, required String data, super.key})
      : _id = id,
        _articleId = articleId,
        _title = title,
        _data = data;

  final int _id;
  final int _articleId;
  final String _title;
  final String _data;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final dividerColor = ref.read(colorBBBBBB);

      final titleTextStyle = ref.read(myaccountArticleItemTitleStyle);
      final dataTextStyle = ref.read(myaccountArticleItemDateStyle);
      final commentDeleteTextStyle = ref.watch(articleDetailCommentDeleteStyle);

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SizedBox(
              width: double.infinity,
              height: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: titleTextStyle,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        _data,
                        style: dataTextStyle,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Spacer(
                        flex: 25,
                      ),
                      InkWell(
                        onTap: () {
                          // TODO: 댓글 삭제 기능 추가
                          log('댓글 삭제 기능 추가');
                          _showDeleteDialog(
                            context: context,
                            textStyle: commentDeleteTextStyle,
                            ref: ref,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Assets.images.articleDetail.deleteIcon.image(
                            width: 6,
                            height: 20,
                          ),
                        ),
                      ),
                      const Spacer(
                        flex: 36,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ArticleCreateDivider(
              thickness: 1,
              color: dividerColor,
            ),
          ),
        ],
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
                  context: context,
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
    required BuildContext context,
  }) async {
    final preferenceStorage = ref.watch(preferenceStorageProvider);

    final nurbanRepository = ref.watch(nurbanRepositoryProvider);

    final storage = preferenceStorage.asData?.value;
    final token = storage?.getToken() ?? '__empty__';

    log('token: $token');

    final result = await nurbanRepository.nurbanCommentDelete(
      token: token,
      commentId: _id,
      articleId: _articleId,
    );

    log('comment delete result : $result');

    if (result == 'nurbancomment_deleted') {
      Future.delayed(const Duration(milliseconds: 500), () {
        final preferenceStorage = ref.watch(preferenceStorageProvider);
        final storage = preferenceStorage.asData?.value;
        final token = storage?.getToken() ?? '__empty__';

        final profileCommentProvider = ref.watch(getProfileCommentProvider(
            (token, 0, 10)
        ));

        final uuid = ref.read(articleCreateUuidNavigationProvider);

        // TODO myaccount navigation 조정해야 될듯.

        ref.watch(nurbanCommentIdProvider.notifier).set(
          commentId: -1,
          uuid: uuid,
        );
      });
    }
  }

}
