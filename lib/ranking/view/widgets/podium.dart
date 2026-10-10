import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 시상대 한 칸에 넣을 값
typedef PodiumEntry = ({
  int rank,
  String badgeUrl,
  String nickname,
  List<String> insigniaUrls,
  int lossAmount,
  int likeCount,
});

/// 시상대 3열(2위 / 1위 / 3위, 아래 정렬). 1위는 honeyTint + honeyLine + 왕관 + 배지 60, 2·3위는 surface + 배지 48.
/// 항목이 3개보다 적으면 있는 칸만 채운다.
class Podium extends StatelessWidget {
  const Podium({required this.entries, super.key});

  /// 순위 순서(1위부터)
  final List<PodiumEntry> entries;

  PodiumEntry? _at(int rank) => entries.length >= rank ? entries[rank - 1] : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NbkSpacing.screen,
        vertical: NbkSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: PodiumColumn(entry: _at(2))),
          const SizedBox(width: NbkSpacing.sm + NbkSpacing.xxs),
          Expanded(child: PodiumColumn(entry: _at(1))),
          const SizedBox(width: NbkSpacing.sm + NbkSpacing.xxs),
          Expanded(child: PodiumColumn(entry: _at(3))),
        ],
      ),
    );
  }
}

class PodiumColumn extends StatelessWidget {
  const PodiumColumn({required this.entry, super.key});

  /// null 이면 빈 칸(그 순위에 아무도 없다)
  final PodiumEntry? entry;

  static final _comma = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final entry = this.entry;
    final first = entry?.rank == 1;
    final avatar = first ? NbkSize.avatarPodium : NbkSize.avatarRank;

    return Container(
      padding: EdgeInsets.fromLTRB(
        NbkSpacing.md,
        first ? NbkSpacing.lg : NbkSpacing.xxl,
        NbkSpacing.md,
        NbkSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: first ? NbkColors.honeyTint : NbkColors.surface,
        border: first ? Border.all(color: NbkColors.honeyLine) : null,
        borderRadius: BorderRadius.circular(NbkRadius.cardLg),
      ),
      child: entry == null
          ? SizedBox(height: avatar + NbkSpacing.xxxl)
          : Column(
              children: [
                if (first) ...[
                  const Icon(Icons.workspace_premium, size: NbkSize.icon, color: NbkColors.honey),
                  const SizedBox(height: NbkSpacing.sm),
                ],
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(NbkSpacing.xs),
                      decoration: BoxDecoration(
                        color: NbkColors.bg,
                        borderRadius: BorderRadius.circular(NbkRadius.avatarLg),
                      ),
                      child: NbkBadge(url: entry.badgeUrl, size: avatar, radius: NbkRadius.avatarMd),
                    ),
                    Positioned(
                      left: -NbkSpacing.sm,
                      bottom: -NbkSpacing.xs,
                      child: _RankBadge(rank: entry.rank),
                    ),
                  ],
                ),
                const SizedBox(height: NbkSpacing.md),
                Text(
                  entry.nickname,
                  style: NbkTypography.labelStrong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.insigniaUrls.isNotEmpty) ...[
                  const SizedBox(height: NbkSpacing.xs),
                  InsigniaImage(url: entry.insigniaUrls.first),
                ],
                const SizedBox(height: NbkSpacing.sm),
                LossAmount(
                  amount: entry.lossAmount,
                  size: first ? LossAmountSize.podiumFirst : LossAmountSize.podium,
                  compact: true,
                ),
                const SizedBox(height: NbkSpacing.xs),
                Text(
                  Strings.recommend(_comma.format(entry.likeCount)),
                  style: NbkTypography.countCaption,
                ),
              ],
            ),
    );
  }
}

/// 배지 왼쪽 아래 순위 뱃지(1위 honey/onHoney, 나머지 text2/흰)
class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final first = rank == 1;
    return Container(
      width: NbkSize.rankBox,
      height: NbkSize.rankBox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: first ? NbkColors.honey : NbkColors.text2,
        borderRadius: BorderRadius.circular(NbkRadius.avatarSm),
        border: Border.all(color: NbkColors.bg, width: NbkSpacing.xxs),
      ),
      child: Text(
        '$rank',
        style: NbkTypography.pill.copyWith(
          color: first ? NbkColors.onHoney : NbkColors.onDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
