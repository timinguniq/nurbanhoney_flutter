import 'package:dio_domain/dio_domain.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_detail/article_detail.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/home/view/widgets/losscut_fab.dart';
import 'package:nurbanhoney/home/view/widgets/post_list_item.dart';
import 'package:nurbanhoney/home/view/widgets/top3_section.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

/// 홈 목록의 글 한 건. 저장소의 `BoardAllType` 과 같은 모양의 레코드라 ViewModel 목록을 그대로 넘길 수 있고,
/// 화면 코드가 data 레이어(`dio_repository`)를 직접 import 하지 않아도 된다.
typedef BoardPost = ({
  int id,
  int board,
  String? thumbnail,
  String title,
  int lossCut,
  String content,
  int commentCount,
  int likeCount,
  String createdAt,
  int userId,
  String nickname,
  String? badge,
  String insignia,
  Reaction myReaction,
});

/// 홈 게시판 목록 UI. 주식·코인 탭이 ViewModel 만 다르게 해서 공유한다(ViewModel 상태는 밖에서 받는다).
/// Top3 → 8px 띠 → 글 목록. 첫 로딩은 스켈레톤, 비면 [EmptyState] + [첫 글 쓰기], 실패하면 [ErrorState]
/// (+ 네트워크 오류면 상단 [OfflineBanner]). 빈 상태·오류 상태에서는 FAB 를 숨긴다.
class BoardTabView extends ConsumerStatefulWidget {
  const BoardTabView({
    required this.board,
    required this.fetchState,
    required this.items,
    required this.hasNextPage,
    required this.onRefresh,
    required this.onLoadMore,
    super.key,
  });

  /// 1 주식, 2 코인
  final int board;
  final DataFetchStatus fetchState;
  final List<BoardPost> items;
  final bool hasNextPage;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  ConsumerState<BoardTabView> createState() => _BoardTabViewState();
}

class _BoardTabViewState extends ConsumerState<BoardTabView> {
  /// 목록에서 누른 좋아요 결과(글 id → 상태). 서버 목록은 ViewModel 이 갖고 있어 여기서 덮어 보여주고,
  /// 새로고침이 끝나면 그 새로고침보다 먼저 끝난 것만 비워 서버 값으로 돌아간다(더 받기는 유지).
  /// [generation] 은 좋아요 응답이 끝난 시점의 [_refreshGeneration] 이라, 새로고침 중에 끝난 좋아요는 남는다.
  final _likeOverrides = <int, ({bool liked, int count, int generation})>{};
  var _refreshGeneration = 0;

  bool get _isFirstLoading =>
      widget.items.isEmpty &&
      (widget.fetchState is DataFetching || widget.fetchState is DataRefetching);

  /// 새로고침·더 받기가 진행 중이면 더 받기를 또 시작하지 않는다(커서가 섞인다).
  bool get _isFetching =>
      widget.fetchState is DataFetching ||
      widget.fetchState is DataRefetching ||
      widget.fetchState is DataFetchingMore;

  /// 좋아요 생성·취소. 성공하면 돌려받은 새 좋아요 수로 그 글의 표시를 덮는다. 비로그인·실패면 안내 토스트.
  Future<void> _toggleLike(int articleId, {required bool like}) async {
    if (!(ref.read(preferenceStorageProvider).valueOrNull?.hasToken() ?? false)) {
      NbkToast.info(Strings.toastLoginRequired);
      return;
    }
    final repository = ref.read(nurbanRepositoryProvider);
    final int count;
    try {
      count = like
          ? await repository.nurbanLikeCreate(articleId: articleId)
          : await repository.nurbanLikeDelete(articleId: articleId);
    } on ApiFailure catch (e) {
      NbkToast.error(isNetworkError(e) ? Strings.toastNetworkError : Strings.toastLikeFailed);
      return;
    }
    if (!mounted) return;
    setState(() {
      _likeOverrides[articleId] = (liked: like, count: count, generation: _refreshGeneration);
    });
  }

  /// 새로고침(당겨서·다시 시도·글 등록 후). Top3 도 다시 받고, 끝나면 이 새로고침이 시작되기 전에 끝난
  /// 로컬 좋아요 덮어쓰기만 비운다(새로고침 중에 끝난 좋아요는 서버 응답보다 새 값이므로 남긴다).
  Future<void> _refresh() async {
    final generation = ++_refreshGeneration;
    ref.invalidate(getRankTabProvider);
    await widget.onRefresh();
    if (!mounted) return;
    setState(() => _likeOverrides.removeWhere((_, like) => like.generation < generation));
  }

  void _openArticle(BoardPost item) {
    Navigator.of(context).push(
      ArticleDetailPage.route(board: item.board, articleId: item.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 좋아요를 누를 때 로그인 여부를 바로 읽을 수 있게 저장소를 미리 받아 둔다.
    ref.watch(preferenceStorageProvider);
    final state = widget.fetchState;
    if (state is DataFetchError) {
      return Column(
        children: [
          if (isNetworkError(state.error)) const OfflineBanner(),
          Expanded(
            child: ErrorState(
              errorCode: errorCodeOf(state.error),
              onRetry: _refresh,
            ),
          ),
        ],
      );
    }

    final isEmpty = !_isFirstLoading && widget.items.isEmpty;
    final toInsignia = ref.read(convertToInsignia);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: Top3Section()),
            const SliverToBoxAdapter(child: SectionBand()),
            if (_isFirstLoading)
              const SliverToBoxAdapter(
                child: Shimmer(
                  child: Column(children: [PostItemSkeleton(), PostItemSkeleton()]),
                ),
              )
            else if (isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  title: Strings.homeEmptyTitle(Strings.boardName(widget.board)),
                  message: Strings.homeEmptyMessage,
                  ctaLabel: Strings.firstPostCta,
                  ctaIcon: Icons.edit_outlined,
                  onCta: () => startLossCutCreate(
                    context,
                    ref,
                    board: widget.board,
                    onCreated: _refresh,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == widget.items.length * 2 - 1) return _footer();
                    if (index.isOdd) return const Divider();
                    final item = widget.items[index ~/ 2];
                    final like = _likeOverrides[item.id];
                    return PostListItem(
                      key: ValueKey('post-${item.board}-${item.id}'),
                      badgeUrl: item.badge,
                      nickname: item.nickname,
                      insigniaUrls: toInsignia(item.insignia),
                      timeLabel: formatRelativeTime(item.createdAt),
                      lossAmount: item.lossCut,
                      title: item.title,
                      body: item.content,
                      thumbnailUrl: item.thumbnail,
                      likeCount: like?.count ?? item.likeCount,
                      liked: like?.liked ?? item.myReaction == Reaction.like,
                      commentCount: item.commentCount,
                      onTap: () => _openArticle(item),
                      onToggleLike: ({required bool like}) => _toggleLike(item.id, like: like),
                    );
                  },
                  childCount: widget.items.length * 2,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: isEmpty || _isFirstLoading
          ? null
          : LossCutFab(board: widget.board, onCreated: _refresh),
    );
  }

  /// 목록 끝: 받는 중(새로고침·더 받기)이면 스켈레톤만, 다음 페이지가 있으면 끝에 닿을 때 받는다.
  /// 아니면 FAB 에 가리지 않을 여백.
  Widget _footer() {
    if (_isFetching) return const Shimmer(child: PostItemSkeleton());
    if (widget.hasNextPage) {
      return LoadMoreTrigger(
        onVisible: widget.onLoadMore,
        child: const Shimmer(child: PostItemSkeleton()),
      );
    }
    return const SizedBox(height: NbkSize.fab + NbkSpacing.xxxl);
  }
}
