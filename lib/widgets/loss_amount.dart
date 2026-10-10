import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/loss_format_utils.dart';

enum LossAmountSize {
  /// 22 — 홈 목록
  list,

  /// 24 — 글 상세 손실액 카드
  detail,

  /// 20 — 홈 Top3 카드, 내 순위 바
  top3,

  /// 17 — 시상대 1위
  podiumFirst,

  /// 14 — 시상대 2·3위
  podium,

  /// 15 — 랭킹 4위 이하 행
  rank,

  /// 12 — 내 글 목록 캡션
  caption,
}

/// 손실액 표기. 목록·상세·랭킹 모두 이 위젯만 쓴다: `-1,250,000원`, [compact] 면 `-1,248만원`/`-1.2억원`.
class LossAmount extends StatelessWidget {
  const LossAmount({
    required this.amount,
    this.size = LossAmountSize.list,
    this.compact = false,
    super.key,
  });

  final int amount;
  final LossAmountSize size;
  final bool compact;

  TextStyle get _style => switch (size) {
        LossAmountSize.list => NbkTypography.lossList,
        LossAmountSize.detail => NbkTypography.lossDetail,
        LossAmountSize.top3 => NbkTypography.lossTop3,
        LossAmountSize.podiumFirst => NbkTypography.lossPodiumFirst,
        LossAmountSize.podium => NbkTypography.lossPodium,
        LossAmountSize.rank => NbkTypography.lossRank,
        LossAmountSize.caption => NbkTypography.lossCaption,
      };

  @override
  Widget build(BuildContext context) {
    return Text(
      formatLossAmount(amount, compact: compact),
      style: _style,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}
