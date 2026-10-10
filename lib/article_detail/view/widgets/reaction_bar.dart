import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 좋아요·싫어요 필 버튼 2개. 선택 상태와 수는 기존처럼 [getFreeArticleProvider] 의 `myRating`·카운트에서
/// 시작하고, 누르면 nurbanRepository 로 생성·삭제한 뒤 돌려받은 수로 갱신한다(기존 LikeDislikeBoard 의 로직).
class ReactionBar extends ConsumerStatefulWidget {
  const ReactionBar({required this.articleId, super.key});

  final int articleId;

  @override
  ConsumerState<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends ConsumerState<ReactionBar> {
  static const _emptyToken = '__empty__';

  /// 서버 값 위에 덮어 보여줄 로컬 상태(누른 뒤부터)
  ({int likeCount, int dislikeCount, String myRating})? _local;
  var _busy = false;

  Future<void> _react(
    ReactionKind kind, {
    required String token,
    required ({int likeCount, int dislikeCount, String myRating}) current,
  }) async {
    if (_busy) return;
    if (token == _emptyToken) {
      NbkToast.info(Strings.toastLoginRequired);
      return;
    }
    _busy = true;
    final repository = ref.read(nurbanRepositoryProvider);
    final isLike = kind == ReactionKind.like;
    final selectedNow = current.myRating == (isLike ? 'like' : 'dislike');
    try {
      final result = switch ((isLike, selectedNow)) {
        (true, true) => await repository.nurbanLikeDelete(token: token, articleId: widget.articleId),
        (true, false) => await repository.nurbanLikeCreate(token: token, articleId: widget.articleId),
        (false, true) => await repository.nurbanDislikeDelete(token: token, articleId: widget.articleId),
        (false, false) => await repository.nurbanDislikeCreate(token: token, articleId: widget.articleId),
      };
      final count = int.tryParse(result);
      if (count == null) {
        NbkToast.error(Strings.toastReactionFailed);
        return;
      }
      if (!mounted) return;
      setState(() {
        if (isLike) {
          _local = (
            likeCount: count,
            // 싫어요 상태에서 좋아요를 누르면 서버가 싫어요를 거두므로 수를 하나 줄인다(기존 로직).
            dislikeCount: current.myRating == 'dislike' ? current.dislikeCount - 1 : current.dislikeCount,
            myRating: selectedNow ? 'null' : 'like',
          );
        } else {
          _local = (
            likeCount: current.myRating == 'like' ? current.likeCount - 1 : current.likeCount,
            dislikeCount: count,
            myRating: selectedNow ? 'null' : 'dislike',
          );
        }
      });
    } catch (_) {
      NbkToast.error(Strings.toastNetworkError);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(preferenceStorageProvider).valueOrNull?.getToken() ?? _emptyToken;
    final article = ref.watch(getFreeArticleProvider((token, widget.articleId)));
    final server = article.valueOrNull;
    if (server == null) return const SizedBox(height: NbkSize.reactionButton);

    final current = _local ??
        (likeCount: server.likeCount, dislikeCount: server.dislikeCount, myRating: server.myRating);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
      child: Row(
        children: [
          ReactionButton.like(
            count: current.likeCount,
            selected: current.myRating == 'like',
            pill: true,
            onTap: () => _react(ReactionKind.like, token: token, current: current),
          ),
          const SizedBox(width: NbkSpacing.md),
          ReactionButton.dislike(
            count: current.dislikeCount,
            selected: current.myRating == 'dislike',
            pill: true,
            onTap: () => _react(ReactionKind.dislike, token: token, current: current),
          ),
        ],
      ),
    );
  }
}
