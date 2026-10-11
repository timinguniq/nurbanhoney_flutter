import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:share_service/share_service.dart';

/// 홈 '이번 달 손실 Top 3': 헤더('전체보기' → 랭킹 탭) + 가로 스크롤 카드(폭 236, 간격 10).
/// 순위는 응답 순서(index + 1)다. 비면 점선 박스 안내, 실패하면 점선 박스 안에 [다시 시도].
class Top3Section extends ConsumerWidget {
  const Top3Section({super.key});

  static const _request = (offset: 0, limit: 3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranks = ref.watch(getRankTabProvider(_request));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NbkSpacing.screen,
            NbkSpacing.xl,
            NbkSpacing.sm,
            NbkSpacing.md,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: NbkSize.icon,
                color: NbkColors.honeyDeep,
              ),
              const SizedBox(width: NbkSpacing.sm),
              const Expanded(
                child: Text(Strings.top3Title, style: NbkTypography.heading),
              ),
              TextButton(
                onPressed: () => ref
                    .read(homeBottomNavigationProvider.notifier)
                    .select(HomeBottomStatus.rank),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(Strings.seeAll),
                    Icon(Icons.chevron_right, size: NbkSize.iconSm),
                  ],
                ),
              ),
            ],
          ),
        ),
        ranks.when(
          loading: () => const _CardRow(children: [Top3CardSkeleton(), Top3CardSkeleton()]),
          error: (_, __) => _Notice(
            message: Strings.top3Error,
            actionLabel: Strings.retry,
            onAction: () => ref.invalidate(getRankTabProvider(_request)),
          ),
          data: (data) {
            if (data.isEmpty) return const _Notice(message: Strings.top3Empty);
            final toInsignia = ref.read(convertToInsignia);
            return _CardRow(
              children: [
                for (var i = 0; i < data.length; i++)
                  Top3Card(
                    rank: i + 1,
                    badgeUrl: data[i].badge,
                    nickname: data[i].nickname,
                    insigniaUrls: toInsignia(data[i].insignia),
                    lossAmount: data[i].totalLossCut,
                    likeCount: data[i].totalLikeCount,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: NbkSpacing.lg),
      ],
    );
  }
}

/// 가로 스크롤 카드 줄. 로딩이면 스켈레톤이 돌고, 데이터면 다음 카드가 살짝 보인다.
class _CardRow extends StatelessWidget {
  const _CardRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final row = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: NbkSize.top3CardGap),
            children[i],
          ],
        ],
      ),
    );
    final isSkeleton = children.every((child) => child is Top3CardSkeleton);
    return isSkeleton ? Shimmer(child: row) : row;
  }
}

/// 점선 박스 안내(빈 상태·오류)
class _Notice extends StatelessWidget {
  const _Notice({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
      child: DashedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NbkSpacing.lg,
            vertical: NbkSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: NbkTypography.body.copyWith(color: NbkColors.text3),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top3 카드. 1위는 honeyTint + honeyLine, 2·3위는 흰 배경 + line.
class Top3Card extends StatelessWidget {
  const Top3Card({
    required this.rank,
    required this.badgeUrl,
    required this.nickname,
    required this.insigniaUrls,
    required this.lossAmount,
    required this.likeCount,
    super.key,
  });

  final int rank;
  final String? badgeUrl;
  final String nickname;
  final List<String> insigniaUrls;
  final int lossAmount;
  final int likeCount;

  static final _comma = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final first = rank == 1;
    return Container(
      width: NbkSize.top3CardWidth,
      padding: const EdgeInsets.all(NbkSpacing.lg),
      decoration: BoxDecoration(
        color: first ? NbkColors.honeyTint : NbkColors.bg,
        border: Border.all(color: first ? NbkColors.honeyLine : NbkColors.line),
        borderRadius: BorderRadius.circular(NbkRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: NbkSize.rankBox,
                padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.xs + NbkSpacing.xxs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: first ? NbkColors.honey : NbkColors.surface,
                  borderRadius: BorderRadius.circular(NbkRadius.avatarSm),
                ),
                child: Text(
                  Strings.rankLabel(rank),
                  style: NbkTypography.pill.copyWith(
                    color: first ? NbkColors.onHoney : NbkColors.text2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: NbkSpacing.sm),
              Expanded(
                child: AuthorInfo(
                  badgeUrl: badgeUrl,
                  nickname: nickname,
                  insigniaUrls: insigniaUrls,
                ),
              ),
            ],
          ),
          const SizedBox(height: NbkSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: LossAmount(amount: lossAmount, size: LossAmountSize.top3)),
              const SizedBox(width: NbkSpacing.sm),
              const Icon(
                Icons.thumb_up_outlined,
                size: NbkSize.iconXs,
                color: NbkColors.text3,
              ),
              const SizedBox(width: NbkSpacing.xs),
              Text(
                Strings.recommend(_comma.format(likeCount)),
                style: NbkTypography.countCaption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
