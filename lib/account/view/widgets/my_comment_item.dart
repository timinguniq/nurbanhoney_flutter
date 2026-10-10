import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 내 댓글 아이템: 댓글 내용 → 게시판 필 + 원문 제목 › · 날짜. 탭하면 원문 글로, 휴지통은 [onDelete].
class MyCommentItem extends StatelessWidget {
  const MyCommentItem({
    required this.board,
    required this.content,
    required this.articleTitle,
    required this.date,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final int board;
  final String content;
  final String articleTitle;

  /// 이미 `MM.dd` 로 만든 날짜
  final String date;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: NbkSpacing.screen,
          top: NbkSpacing.lg,
          bottom: NbkSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: NbkTypography.commentBody,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: NbkSpacing.sm),
                  Row(
                    children: [
                      NbkPill(label: Strings.boardName(board)),
                      const SizedBox(width: NbkSpacing.sm),
                      Flexible(
                        child: Text(
                          articleTitle,
                          style: NbkTypography.label.copyWith(color: NbkColors.text2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: NbkSpacing.xs),
                      const Icon(
                        Icons.chevron_right,
                        size: NbkSize.iconXs,
                        color: NbkColors.text3,
                      ),
                      Text(' · $date', style: NbkTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
            NbkIconButton(
              icon: Icons.delete_outline,
              color: NbkColors.text3,
              size: NbkSize.reactionIcon,
              tooltip: Strings.delete,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
