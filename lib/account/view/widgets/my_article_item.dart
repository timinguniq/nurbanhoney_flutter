import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 내 글 아이템: 게시판 필 + 제목 1줄 / 날짜 · 조회 / 오른쪽 댓글 수.
/// 내 글 API(`/profile/myarticle`)에는 손실액이 없어 시안의 손실액 캡션은 넣지 못한다.
class MyArticleItem extends StatelessWidget {
  const MyArticleItem({
    required this.board,
    required this.title,
    required this.date,
    required this.viewCount,
    required this.commentCount,
    required this.onTap,
    super.key,
  });

  final int board;
  final String title;

  /// 이미 `yyyy.MM.dd` 로 만든 날짜
  final String date;
  final int viewCount;
  final int commentCount;
  final VoidCallback onTap;

  static final _comma = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NbkSpacing.screen,
          vertical: NbkSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NbkPill(label: Strings.boardName(board)),
                      const SizedBox(width: NbkSpacing.sm),
                      Expanded(
                        child: Text(
                          title,
                          style: NbkTypography.itemTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NbkSpacing.xs + NbkSpacing.xxs),
                  Text(
                    '$date  ${Strings.views(_comma.format(viewCount))}',
                    style: NbkTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: NbkSpacing.md),
            CommentCount(count: commentCount),
          ],
        ),
      ),
    );
  }
}
