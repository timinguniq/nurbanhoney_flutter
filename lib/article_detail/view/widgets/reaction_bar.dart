import 'package:dio_domain/dio_domain.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 좋아요·싫어요 필 버튼 2개. 수와 내 반응은 글 상세가 받은 값([likeCount]·[dislikeCount]·[myReaction])에서
/// 시작하고, 누르면 nurbanRepository 로 생성·삭제한 뒤 돌려받은 수로 갱신한다(기존 LikeDislikeBoard 의 로직).
class ReactionBar extends ConsumerStatefulWidget {
  const ReactionBar({
    required this.articleId,
    required this.likeCount,
    required this.dislikeCount,
    required this.myReaction,
    super.key,
  });

  final int articleId;
  final int likeCount;
  final int dislikeCount;
  final Reaction myReaction;

  @override
  ConsumerState<ReactionBar> createState() => _ReactionBarState();
}

typedef _Counts = ({int likeCount, int dislikeCount, Reaction myReaction});

class _ReactionBarState extends ConsumerState<ReactionBar> {
  /// 서버 값 위에 덮어 보여줄 로컬 상태(누른 뒤부터)
  _Counts? _local;
  var _busy = false;

  Future<void> _react(ReactionKind kind, {required _Counts current}) async {
    if (_busy) return;
    if (!(ref.read(preferenceStorageProvider).valueOrNull?.hasToken() ?? false)) {
      NbkToast.info(Strings.toastLoginRequired);
      return;
    }
    _busy = true;
    final repository = ref.read(nurbanRepositoryProvider);
    final isLike = kind == ReactionKind.like;
    final target = isLike ? Reaction.like : Reaction.dislike;
    final selectedNow = current.myReaction == target;
    try {
      final count = switch ((isLike, selectedNow)) {
        (true, true) => await repository.nurbanLikeDelete(articleId: widget.articleId),
        (true, false) => await repository.nurbanLikeCreate(articleId: widget.articleId),
        (false, true) => await repository.nurbanDislikeDelete(articleId: widget.articleId),
        (false, false) => await repository.nurbanDislikeCreate(articleId: widget.articleId),
      };
      if (!mounted) return;
      setState(() {
        final next = selectedNow ? Reaction.none : target;
        if (isLike) {
          _local = (
            likeCount: count,
            // 싫어요 상태에서 좋아요를 누르면 서버가 싫어요를 거두므로 수를 하나 줄인다(기존 로직).
            dislikeCount: current.myReaction == Reaction.dislike ? current.dislikeCount - 1 : current.dislikeCount,
            myReaction: next,
          );
        } else {
          _local = (
            likeCount: current.myReaction == Reaction.like ? current.likeCount - 1 : current.likeCount,
            dislikeCount: count,
            myReaction: next,
          );
        }
      });
    } on ApiFailure catch (e) {
      NbkToast.error(isNetworkError(e) ? Strings.toastNetworkError : Strings.toastReactionFailed);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 누를 때 로그인 여부를 바로 읽을 수 있게 저장소를 미리 받아 둔다.
    ref.watch(preferenceStorageProvider);
    final current = _local ??
        (likeCount: widget.likeCount, dislikeCount: widget.dislikeCount, myReaction: widget.myReaction);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
      child: Row(
        children: [
          ReactionButton.like(
            count: current.likeCount,
            selected: current.myReaction == Reaction.like,
            pill: true,
            onTap: () => _react(ReactionKind.like, current: current),
          ),
          const SizedBox(width: NbkSpacing.md),
          ReactionButton.dislike(
            count: current.dislikeCount,
            selected: current.myReaction == Reaction.dislike,
            pill: true,
            onTap: () => _react(ReactionKind.dislike, current: current),
          ),
        ],
      ),
    );
  }
}
