import 'dart:async';
import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

class ArticleDetailAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const ArticleDetailAppBar({
    required int board,
    required int articleId,
    required TextStyle appBarTitleStyle,
    required int authorId,
    required String uuid,
    super.key,
  })  : _board = board,
        _articleId = articleId,
        _appBarTitleStyle = appBarTitleStyle,
        _authorId = authorId,
        _uuid = uuid;

  final int _board;
  final int _articleId;
  final TextStyle _appBarTitleStyle;
  final int _authorId;
  final String _uuid;

  @override
  ConsumerState<ArticleDetailAppBar> createState() => _ArticleDetailAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _ArticleDetailAppBarState extends ConsumerState<ArticleDetailAppBar> {
  @override
  Widget build(BuildContext context) {
    final commentDeleteTextStyle = ref.watch(articleDetailCommentDeleteStyle);

    final preferenceStorage = ref.watch(preferenceStorageProvider);
    final storage = preferenceStorage.asData?.value;
    final userId = storage?.getUserId();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 0,
      leading: Container(),
      title: SizedBox(
        width: double.infinity,
        height: 48,
        child: Stack(
          children: [
            // back key icon
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 24,
                height: 24,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Assets.images.articleDetail.backKey.image(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: widget._board == 1
                  ? Text(
                '너반꿀',
                style: widget._appBarTitleStyle,
              )
                  : widget._board == 2
                  ? Text(
                '코인',
                style: widget._appBarTitleStyle,
              )
                  : Text(
                '코인',
                style: widget._appBarTitleStyle,
              ),
            ),
            // TODO: 여기서부터 해야됨. 컨슈머로 확장하고 해야될듯.
            if (userId == widget._authorId)
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    log('delete clicked');
                    _showDeleteDialog(
                      context: context,
                      textStyle: commentDeleteTextStyle,
                      ref: ref,
                      articleId: widget._articleId,
                      uuid: widget._uuid,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
                    child: SizedBox(
                      width: 6,
                      height: 20,
                      child: Assets.images.common.optionIcon.image(),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog({
    required BuildContext context,
    required TextStyle textStyle,
    required WidgetRef ref,
    required int articleId,
    required String uuid,
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
                await deleteArticle(
                  context: context,
                  ref: ref,
                  articleId: articleId,
                  uuid: uuid,
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

  Future<void> deleteArticle({
    required BuildContext context,
    required WidgetRef ref,
    required int articleId,
    required String uuid,
  }) async {
    final preferenceStorage = ref.watch(preferenceStorageProvider);

    final nurbanRepository = ref.watch(nurbanRepositoryProvider);

    final storage = preferenceStorage.asData?.value;
    final token = storage?.getToken() ?? '__empty__';

    log('token: $token');

    final result = await nurbanRepository.nurbanArticleDelete(
      token: token,
      articleId: articleId,
      uuid: uuid,
    );

    log('article delete result : $result');

    if (result == 'nurbanboard_deleted') {
      Fluttertoast.showToast(
          msg: '글이 삭제되었습니다.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          //backgroundColor: ref.read(color000000),
          //textColor: ref.read(colorFFFFFF),
          fontSize: 16.0
      );

      if(context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
