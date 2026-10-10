import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 하단 고정 '내 순위' 바(honeyTint, 모서리 14). [rank] 가 있으면 '27위 닉네임 손실액 ›',
/// 비로그인이면 '로그인하고 내 순위 확인하기', 순위 밖이면 '아직 이번 달 기록이 없어요'.
class MyRankBar extends StatelessWidget {
  const MyRankBar({
    required this.loggedIn,
    required this.onTap,
    this.rank,
    this.nickname,
    this.lossAmount,
    this.loading = false,
    super.key,
  });

  final bool loggedIn;
  final VoidCallback onTap;
  final int? rank;
  final String? nickname;
  final int? lossAmount;
  final bool loading;

  /// 내 순위 줄에서 닉네임이 차지할 수 있는 최대 폭
  static const _nicknameMaxWidth = 96.0;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (loading) {
      // 폭은 남는 자리에 맞춘다(좁은 화면에서 고정 폭은 넘친다).
      content = const Row(
        children: [
          Expanded(child: SkeletonBox(height: NbkSize.iconSm)),
          SizedBox(width: NbkSpacing.xl),
          Expanded(flex: 2, child: SkeletonBox(height: NbkSize.iconSm)),
        ],
      );
    } else if (!loggedIn) {
      content = Row(
        children: [
          Expanded(child: Text(Strings.myRankLoginCta, style: NbkTypography.labelStrong)),
          const Icon(Icons.chevron_right, size: NbkSize.icon, color: NbkColors.honeyDeep),
        ],
      );
    } else if (rank == null) {
      content = Row(
        children: [
          Expanded(child: Text(Strings.myRankNone, style: NbkTypography.label.copyWith(color: NbkColors.text2))),
          const Icon(Icons.chevron_right, size: NbkSize.icon, color: NbkColors.honeyDeep),
        ],
      );
    } else {
      // 좁은 화면에서 '27위 닉네임 -430,000원 ›' 가 한 줄에 안 들어오면 줄이 넘치지 않게 전체를 축소한다.
      content = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Strings.rankLabel(rank!), style: NbkTypography.statValue),
            const SizedBox(width: NbkSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _nicknameMaxWidth),
              child: Text(
                nickname ?? '',
                style: NbkTypography.label.copyWith(color: NbkColors.text3),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: NbkSpacing.md),
            LossAmount(amount: lossAmount ?? 0, size: LossAmountSize.top3),
            const SizedBox(width: NbkSpacing.xs),
            const Icon(Icons.chevron_right, size: NbkSize.icon, color: NbkColors.honeyDeep),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NbkSpacing.screen,
        NbkSpacing.sm,
        NbkSpacing.screen,
        NbkSpacing.md,
      ),
      child: Material(
        color: NbkColors.honeyTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NbkRadius.myRankBar),
          side: const BorderSide(color: NbkColors.honeyLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NbkSpacing.lg,
              vertical: NbkSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NbkSpacing.md,
                    vertical: NbkSpacing.xs + NbkSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: NbkColors.honey,
                    borderRadius: BorderRadius.circular(NbkRadius.pill),
                  ),
                  child: Text(
                    Strings.myRank,
                    style: NbkTypography.buttonSmall.copyWith(color: NbkColors.onHoney),
                  ),
                ),
                const SizedBox(width: NbkSpacing.md),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
