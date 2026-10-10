import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/view/widgets/comment_item.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:share_service/share_service.dart';

/// 댓글 헤더('댓글 N', N 은 honeyDeep) + 목록. 비면 말풍선 빈 상태, 받지 못하면 [다시 시도].
/// 목록은 기존처럼 [getNurbanCommentsProvider] 가 주는 범위(최근 10개)만 보여준다.
class CommentSection extends ConsumerWidget {
  const CommentSection({
    required this.articleId,
    required this.commentCount,
    required this.myUserId,
    required this.onDelete,
    required this.onRetry,
    super.key,
  });

  final int articleId;
  final int commentCount;
  final int? myUserId;
  final ValueChanged<int> onDelete;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(getNurbanCommentsProvider(articleId));
    final toInsignia = ref.read(convertToInsignia);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NbkSpacing.screen,
            NbkSpacing.xl,
            NbkSpacing.screen,
            NbkSpacing.sm,
          ),
          child: Text.rich(
            TextSpan(
              text: '${Strings.commentsHeader} ',
              style: NbkTypography.heading,
              children: [
                TextSpan(
                  text: '$commentCount',
                  style: NbkTypography.heading.copyWith(color: NbkColors.honeyDeep),
                ),
              ],
            ),
          ),
        ),
        comments.when(
          loading: () => Shimmer(
            child: Column(children: [for (var i = 0; i < 2; i++) const _CommentSkeleton()]),
          ),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(NbkSpacing.lg),
              child: NbkButton(
                label: Strings.retry,
                icon: Icons.refresh,
                variant: NbkButtonVariant.outline,
                expand: false,
                onPressed: onRetry,
              ),
            ),
          ),
          data: (data) {
            if (data.isEmpty) {
              return const EmptyState(
                title: Strings.emptyCommentsTitle,
                message: Strings.emptyCommentsMessage,
                icon: Icons.chat_bubble_outline,
                showTile: false,
              );
            }
            return Column(
              children: [
                for (final comment in data)
                  CommentItem(
                    badgeUrl: comment.badge,
                    nickname: comment.nickname,
                    insigniaUrls: toInsignia(comment.insignia),
                    content: comment.content,
                    mine: myUserId != null && comment.userId == myUserId,
                    onDelete: () => onDelete(comment.id),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CommentSkeleton extends StatelessWidget {
  const _CommentSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: NbkSpacing.screen, vertical: NbkSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: NbkSize.avatarComment,
            height: NbkSize.avatarComment,
            radius: NbkRadius.avatarComment,
          ),
          SizedBox(width: NbkSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 80),
                SizedBox(height: NbkSpacing.sm),
                SkeletonBox(width: 220),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
