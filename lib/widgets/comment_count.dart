import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 댓글 수(말풍선 아이콘 + 숫자). 누를 수 있으면 [onTap] 을 준다.
class CommentCount extends StatelessWidget {
  const CommentCount({required this.count, this.onTap, super.key});

  final int count;
  final VoidCallback? onTap;

  static final _comma = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
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
              const Icon(
                Icons.chat_bubble_outline,
                size: NbkSize.reactionIcon,
                color: NbkColors.text3,
              ),
              const SizedBox(width: NbkSpacing.xs + NbkSpacing.xxs),
              Text(_comma.format(count), style: NbkTypography.countLabel),
            ],
          ),
        ),
      ),
    );
  }
}
