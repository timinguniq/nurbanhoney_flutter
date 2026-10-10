import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/account/view/widgets/account_skeletons.dart';
import 'package:nurbanhoney/account/view/widgets/activity_summary_card.dart';
import 'package:nurbanhoney/account/view/widgets/my_article_item.dart';
import 'package:nurbanhoney/account/view/widgets/my_comment_item.dart';
import 'package:nurbanhoney/account/view/widgets/paged_sliver_list.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/myaccount_edit/myaccount_edit.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:share_service/share_service.dart';

/// 로그인한 내 계정: 프로필 블록 → 활동 요약 → '내 글 | 내 댓글' 탭 → 목록(offset 10개씩 무한 스크롤).
/// 당겨서 새로고침하면 프로필과 두 목록을 모두 다시 받는다.
class AccountProfileView extends ConsumerStatefulWidget {
  const AccountProfileView({required this.token, super.key});

  final String token;

  @override
  ConsumerState<AccountProfileView> createState() => _AccountProfileViewState();
}

class _AccountProfileViewState extends ConsumerState<AccountProfileView> {
  static const _pageSize = 10;
  static const _commentDeleted = 'nurbancomment_deleted';

  var _tab = 0;
  var _articleOffsets = <int>[0];
  var _commentOffsets = <int>[0];

  Future<void> _refresh() async {
    setState(() {
      _articleOffsets = [0];
      _commentOffsets = [0];
    });
    ref.invalidate(getProfileArticleProvider);
    ref.invalidate(getProfileCommentProvider);
    ref.invalidate(getProfileProvider);
    try {
      await ref.read(getProfileProvider(widget.token).future);
    } catch (_) {
      // 오류는 build 의 ErrorState 가 보여준다.
    }
  }

  Future<void> _deleteComment({required int commentId, required int articleId}) async {
    final confirmed = await showConfirmSheet(
      context,
      title: Strings.deleteCommentTitle,
      message: Strings.deleteCommentMessage,
      confirmLabel: Strings.delete,
    );
    if (!confirmed || !mounted) return;

    String result;
    try {
      result = await ref.read(nurbanRepositoryProvider).nurbanCommentDelete(
            token: widget.token,
            commentId: commentId,
            articleId: articleId,
          );
    } catch (_) {
      result = '';
    }
    if (!mounted) return;
    if (result != _commentDeleted) {
      NbkToast.error(Strings.toastCommentDeleteFailed);
      return;
    }
    NbkToast.success(Strings.toastCommentDeleted);
    setState(() => _commentOffsets = [0]);
    ref.invalidate(getProfileCommentProvider);
    ref.invalidate(getProfileProvider);
  }

  void _showPointsSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            NbkSpacing.screen,
            NbkSpacing.sm,
            NbkSpacing.screen,
            NbkSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(Strings.pointsRuleTitle, style: NbkTypography.title),
              const SizedBox(height: NbkSpacing.sm),
              Text(
                Strings.pointsRule,
                style: NbkTypography.body.copyWith(color: NbkColors.text2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(getProfileProvider(widget.token));

    return profile.when(
      loading: () => const AccountProfileSkeleton(),
      error: (error, _) => ErrorState(
        errorCode: errorCodeOf(error),
        onRetry: () => ref.invalidate(getProfileProvider),
      ),
      data: (data) {
        final List<String> insignias =
            ref.read(convertToInsignia)(data.insigniaShow);
        final description =
            data.description == 'null' ? '' : data.description.trim();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            // 내용이 화면보다 짧거나 비어 있어도 당겨서 새로고침이 되게 한다.
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NbkSpacing.screen,
                    vertical: NbkSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AuthorInfo(
                          badgeUrl: data.badge,
                          nickname: data.nickname,
                          insigniaUrls: insignias,
                          size: AuthorInfoSize.profile,
                          subtitle: description.isEmpty
                              ? Strings.descriptionPlaceholder
                              : description,
                        ),
                      ),
                      const SizedBox(width: NbkSpacing.md),
                      NbkPillButton(
                        label: Strings.edit,
                        variant: NbkPillButtonVariant.outline,
                        onPressed: () =>
                            Navigator.of(context).push(MyaccountEditPage.route()),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ActivitySummaryCard(
                  articleCount: data.myArticleCount,
                  commentCount: data.myCommentCount,
                  point: data.point,
                  onPointHelp: _showPointsSheet,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: NbkSpacing.xl)),
              SliverToBoxAdapter(
                child: NbkSegmentTabs(
                  labels: const [Strings.myArticles, Strings.myComments],
                  counts: [data.myArticleCount, data.myCommentCount],
                  index: _tab,
                  onChanged: (index) => setState(() => _tab = index),
                ),
              ),
              if (_tab == 0) _articleList() else _commentList(),
            ],
          ),
        );
      },
    );
  }

  Widget _articleList() {
    return PagedSliverList(
      pages: [
        for (final offset in _articleOffsets)
          ref.watch(getProfileArticleProvider((widget.token, offset, _pageSize))),
      ],
      pageSize: _pageSize,
      skeleton: const AccountListRowSkeleton(),
      empty: const EmptyState(
        title: Strings.emptyMyArticlesTitle,
        message: Strings.emptyMyArticlesMessage,
      ),
      onLoadMore: () =>
          setState(() => _articleOffsets = [..._articleOffsets, _articleOffsets.length * _pageSize]),
      onRetry: (page) => ref.invalidate(
        getProfileArticleProvider((widget.token, _articleOffsets[page], _pageSize)),
      ),
      itemBuilder: (item) => MyArticleItem(
        board: item.board,
        title: item.title,
        date: formatDate(item.createdAt, dotDateFormat),
        viewCount: item.count,
        commentCount: item.commentCount,
        onTap: () => Navigator.of(context).push(
          ArticleDetailPage.route(board: item.board, articleId: item.id),
        ),
      ),
    );
  }

  Widget _commentList() {
    return PagedSliverList(
      pages: [
        for (final offset in _commentOffsets)
          ref.watch(getProfileCommentProvider((widget.token, offset, _pageSize))),
      ],
      pageSize: _pageSize,
      skeleton: const AccountListRowSkeleton(),
      empty: const EmptyState(
        title: Strings.emptyMyCommentsTitle,
        message: Strings.emptyMyCommentsMessage,
        icon: Icons.chat_bubble_outline,
      ),
      onLoadMore: () =>
          setState(() => _commentOffsets = [..._commentOffsets, _commentOffsets.length * _pageSize]),
      onRetry: (page) => ref.invalidate(
        getProfileCommentProvider((widget.token, _commentOffsets[page], _pageSize)),
      ),
      itemBuilder: (item) => MyCommentItem(
        board: item.board,
        content: item.content,
        articleTitle: item.title,
        date: formatDate(item.createdAt, shortDateFormat),
        onTap: () => Navigator.of(context).push(
          ArticleDetailPage.route(board: item.board, articleId: item.articleId),
        ),
        onDelete: () => _deleteComment(commentId: item.id, articleId: item.articleId),
      ),
    );
  }
}
