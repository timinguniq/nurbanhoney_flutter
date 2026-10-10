import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 활동 요약 3칸 카드(게시글 / 댓글 / 포인트). 포인트 숫자는 honeyDeep, 라벨 옆 `?` 는 [onPointHelp].
class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({
    required this.articleCount,
    required this.commentCount,
    required this.point,
    required this.onPointHelp,
    super.key,
  });

  final int articleCount;
  final int commentCount;
  final int point;
  final VoidCallback onPointHelp;

  static final _comma = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: NbkColors.line),
          borderRadius: BorderRadius.circular(NbkRadius.cardLg),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: _stat(Strings.statArticles, articleCount)),
              const VerticalDivider(),
              Expanded(child: _stat(Strings.statComments, commentCount)),
              const VerticalDivider(),
              Expanded(
                child: _stat(Strings.statPoints, point, highlight: true, onHelp: onPointHelp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, int value, {bool highlight = false, VoidCallback? onHelp}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NbkSpacing.lg),
      child: Column(
        children: [
          Text(
            _comma.format(value),
            style: NbkTypography.statValue.copyWith(
              color: highlight ? NbkColors.honeyDeep : NbkColors.text1,
            ),
          ),
          const SizedBox(height: NbkSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: NbkTypography.label.copyWith(
                  color: NbkColors.text3,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (onHelp != null) ...[
                const SizedBox(width: NbkSpacing.xs),
                InkResponse(
                  onTap: onHelp,
                  radius: NbkSize.iconSm,
                  child: const Icon(
                    Icons.help_outline,
                    size: NbkSize.iconXs,
                    color: NbkColors.text3,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
