import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 4위 이하 행(높이 60): 순위 숫자(폭 28) + 배지 36 + 닉네임·휘장 1개 / 오른쪽 손실액·추천 N. 탭 동작 없음.
class RankRow extends StatelessWidget {
  const RankRow({
    required this.rank,
    required this.badgeUrl,
    required this.nickname,
    required this.insigniaUrls,
    required this.lossAmount,
    required this.likeCount,
    super.key,
  });

  final int rank;
  final String badgeUrl;
  final String nickname;
  final List<String> insigniaUrls;
  final int lossAmount;
  final int likeCount;

  static final _comma = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NbkSize.rankRow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
        child: Row(
          children: [
            SizedBox(
              width: NbkSize.rankNumberWidth,
              child: Text('$rank', style: NbkTypography.rankNumber),
            ),
            const SizedBox(width: NbkSpacing.md),
            NbkBadge(url: badgeUrl, size: NbkSize.avatarMd, radius: NbkRadius.avatarMd),
            const SizedBox(width: NbkSpacing.md),
            // 닉네임 3 : 휘장 1 로 폭을 나눠 금액이 넓어도 줄이 넘치지 않는다(휘장은 모자라면 잘린다).
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Text(
                      nickname,
                      style: NbkTypography.itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (insigniaUrls.isNotEmpty) ...[
                    const SizedBox(width: NbkSpacing.xs + NbkSpacing.xxs),
                    Flexible(
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1,
                          child: InsigniaImage(url: insigniaUrls.first),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: NbkSpacing.md),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LossAmount(amount: lossAmount, size: LossAmountSize.rank),
                const SizedBox(height: NbkSpacing.xxs),
                Text(
                  Strings.recommend(_comma.format(likeCount)),
                  style: NbkTypography.countCaption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
