import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/gen/assets.gen.dart';
import 'package:nurbanhoney_ui_service/nurbanhoney_ui_service.dart';

class StockListItem extends StatelessWidget {
  const StockListItem({
    required int id,
    required String title,
    required String content,
    required String lossCut,
    required String commentCount,
    required String thumbnail,
    required String author,
    required String badge,
    required List<String> insigniaList,
    required String date,
    required String likeCount,
    required VoidCallback onTap,
    super.key,
  })  : _id = id,
        _title = title,
        _content = content,
        _lossCut = lossCut,
        _commentCount = commentCount,
        _author = author,
        _badge = badge,
        _insigniaList = insigniaList,
        _date = date,
        _likeCount = likeCount,
        _thumbnail = thumbnail,
        _onTap = onTap;

  final int _id;
  final String _title;
  final String _content;
  final String _lossCut;
  final String _commentCount;
  final String _author;
  final String _badge;
  final List<String> _insigniaList;
  final String _date;
  final String _likeCount;
  final String _thumbnail;
  final VoidCallback _onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (_, WidgetRef ref, __) {
      final authorStyle = ref.read(boardListItemAuthor);
      final lossCutStyle = ref.read(stockTabLossCutStyle);
      final titleStyle = ref.read(stockTabTitleStyle);
      final contentStyle = ref.read(stockTabContentStyle);
      final likeStyle = ref.read(stockTabLikeStyle);
      log('lossCut : $_lossCut');
      log('content: $_content');
      var f = NumberFormat('###,###,###,###');

      return InkWell(
        onTap: _onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserInfo(
                  onTap: () {
                    log('UserInfo clicked');
                  },
                  badge: _badge,
                  nickname: _author,
                  authorTextStyle: authorStyle,
                  insigniaList: _insigniaList,
                ),
                InkWell(
                  onTap: () {
                    log('delete clicked');
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
              ],
            ),

            const SizedBox(height: 12),

            /// 손실액
            Text(
              '-${f.format(int.parse(_lossCut))}원',
              style: lossCutStyle,
            ),

            const SizedBox(height: 8),

            /// 타이틀
            Text(
              _title,
              style: titleStyle,
            ),

            const SizedBox(height: 8),

            /// 내용
            Text(
              _content,
              style: contentStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            /// 썸네일
            SizedBox(
              width: double.infinity,
              height: 100,
              child: CachedNetworkImage(
                imageUrl: _thumbnail,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) =>
                    Assets.images.home.nurbanSymbol.image(),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            /// 유저 액션(댓글, 좋아요)
            UserAction(
              articleId: _id,
              commentCount: _commentCount,
              likeCount: _likeCount,
              textStyle: likeStyle,
            ),

            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}

class UserAction extends StatelessWidget {
  const UserAction({
    required int articleId,
    required String commentCount,
    required String likeCount,
    required TextStyle textStyle,
    super.key,
  })  : _articleId = articleId,
        _commentCount = commentCount,
        _likeCount = likeCount,
        _textStyle = textStyle;

  final int _articleId;
  final String _commentCount;
  final String _likeCount;
  final TextStyle _textStyle;

  @override
  Widget build(BuildContext context) {
    var f = NumberFormat('###,###,###,###');
    return Row(
      children: [
        /// 댓글
        InkWell(
          onTap: () {
            log('comment clicked');
          },
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Assets.images.common.commentIcon.image(),
              ),
              const SizedBox(width: 6),
              Text(
                f.format(int.parse(_commentCount)),
                style: _textStyle,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        /// 좋아요
        InkWell(
          onTap: () {
            log('like clicked');
          },
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Assets.images.common.likeIcon.image(),
              ),
              const SizedBox(width: 6),
              Text(
                f.format(int.parse(_likeCount)),
                style: _textStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
