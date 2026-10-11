import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 홈 목록 아이템(주식·코인 공용): 작성자 + 상대 시간 → 손실액 → 제목 1줄 → 본문 2줄 → 썸네일(있을 때만)
/// → 좋아요 + 댓글 수. 좋아요 상태([liked]·[likeCount])는 부모가 들고 있고, 누르면 [onToggleLike] 만 부른다
/// (응답을 기다리는 동안 다시 눌리지 않는다).
class PostListItem extends StatefulWidget {
  const PostListItem({
    required this.badgeUrl,
    required this.nickname,
    required this.insigniaUrls,
    required this.timeLabel,
    required this.lossAmount,
    required this.title,
    required this.body,
    required this.thumbnailUrl,
    required this.likeCount,
    required this.liked,
    required this.commentCount,
    required this.onTap,
    required this.onToggleLike,
    super.key,
  });

  final String? badgeUrl;
  final String nickname;
  final List<String> insigniaUrls;

  /// '2시간 전' 같은 상대 시간
  final String timeLabel;
  final int lossAmount;
  final String title;
  final String body;

  /// 비어 있으면 썸네일 영역을 그리지 않는다
  /// 첫 사진 URL. 없으면 null.
  final String? thumbnailUrl;
  final int likeCount;
  final bool liked;
  final int commentCount;
  final VoidCallback onTap;

  /// [like] 가 true 면 좋아요 생성, false 면 취소. 결과 반영은 부모가 한다.
  final Future<void> Function({required bool like}) onToggleLike;

  @override
  State<PostListItem> createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  var _busy = false;

  Future<void> _toggleLike() async {
    if (_busy) return;
    _busy = true;
    try {
      await widget.onToggleLike(like: !widget.liked);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.thumbnailUrl;
    final thumbnail = url == null || url.isEmpty ? null : url;

    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NbkSpacing.screen,
          vertical: NbkSpacing.listItemVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AuthorInfo(
                    badgeUrl: widget.badgeUrl,
                    nickname: widget.nickname,
                    insigniaUrls: widget.insigniaUrls,
                  ),
                ),
                const SizedBox(width: NbkSpacing.sm),
                Text(widget.timeLabel, style: NbkTypography.caption),
              ],
            ),
            const SizedBox(height: NbkSpacing.sm),
            LossAmount(amount: widget.lossAmount),
            const SizedBox(height: NbkSpacing.xs),
            Text(
              widget.title,
              style: NbkTypography.listTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: NbkSpacing.xs),
            Text(
              widget.body,
              style: NbkTypography.listBody,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (thumbnail != null) ...[
              const SizedBox(height: NbkSpacing.md),
              NbkThumbnail(url: thumbnail),
            ],
            const SizedBox(height: NbkSpacing.sm),
            Row(
              children: [
                ReactionButton.like(
                  count: widget.likeCount,
                  selected: widget.liked,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: NbkSpacing.md),
                CommentCount(count: widget.commentCount, onTap: widget.onTap),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
