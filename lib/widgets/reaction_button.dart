import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';

enum ReactionKind { like, dislike }

/// 좋아요/싫어요 카운터. [selected] 는 글의 내 반응(Reaction)으로 초기화한다.
/// 기본은 목록용 인라인(아이콘 + 숫자), [pill] 이면 상세용 필 버튼('좋아요 35', 높이 44).
class ReactionButton extends StatelessWidget {
  const ReactionButton.like({
    required this.count,
    required this.selected,
    required this.onTap,
    this.pill = false,
    super.key,
  }) : kind = ReactionKind.like;

  const ReactionButton.dislike({
    required this.count,
    required this.selected,
    required this.onTap,
    this.pill = false,
    super.key,
  }) : kind = ReactionKind.dislike;

  final ReactionKind kind;
  final int count;
  final bool selected;
  final VoidCallback? onTap;
  final bool pill;

  static final _comma = NumberFormat('#,###');

  IconData get _icon => switch ((kind, selected)) {
        (ReactionKind.like, true) => Icons.thumb_up,
        (ReactionKind.like, false) => Icons.thumb_up_outlined,
        (ReactionKind.dislike, true) => Icons.thumb_down,
        (ReactionKind.dislike, false) => Icons.thumb_down_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final countText = _comma.format(count);
    final (iconColor, textColor) = switch ((kind, selected)) {
      (ReactionKind.like, true) => (NbkColors.honey, NbkColors.honeyDeep),
      (ReactionKind.dislike, true) => (NbkColors.loss, NbkColors.loss),
      (_, false) when pill => (NbkColors.text2, NbkColors.text2),
      (_, false) => (NbkColors.text3, NbkColors.text3),
    };

    if (!pill) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NbkRadius.card),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: NbkSize.tapMin),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: NbkSize.reactionIcon, color: iconColor),
                const SizedBox(width: NbkSpacing.xs + NbkSpacing.xxs),
                Text(
                  countText,
                  style: NbkTypography.countLabel.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final (background, border) = switch ((kind, selected)) {
      (ReactionKind.like, true) => (NbkColors.honeyTint, NbkColors.honey),
      (ReactionKind.dislike, true) => (NbkColors.lossTint, NbkColors.loss),
      (_, false) => (NbkColors.bg, NbkColors.line),
    };
    final label = kind == ReactionKind.like ? Strings.like : Strings.dislike;

    return Material(
      color: background,
      shape: StadiumBorder(side: BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: NbkSize.reactionButton,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: NbkSize.iconSm, color: iconColor),
                const SizedBox(width: NbkSpacing.xs + NbkSpacing.xxs),
                Text(
                  '$label $countText',
                  style: NbkTypography.buttonSmall.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
