import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 댓글 한 건: 배지 32 + 닉네임·휘장 + 내용. 내 댓글이면 오른쪽 휴지통([onDelete]).
class CommentItem extends StatelessWidget {
  const CommentItem({
    required this.badgeUrl,
    required this.nickname,
    required this.insigniaUrls,
    required this.content,
    required this.mine,
    required this.onDelete,
    super.key,
  });

  final String? badgeUrl;
  final String nickname;
  final List<String> insigniaUrls;
  final String content;
  final bool mine;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NbkSpacing.screen,
        NbkSpacing.md,
        mine ? NbkSpacing.xs : NbkSpacing.screen,
        NbkSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AuthorInfo(
              badgeUrl: badgeUrl,
              nickname: nickname,
              insigniaUrls: insigniaUrls,
              size: AuthorInfoSize.comment,
              subtitle: content,
            ),
          ),
          if (mine)
            NbkIconButton(
              icon: Icons.delete_outline,
              color: NbkColors.text3,
              size: NbkSize.reactionIcon,
              tooltip: Strings.delete,
              onTap: onDelete,
            ),
        ],
      ),
    );
  }
}
