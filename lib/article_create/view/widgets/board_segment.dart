import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 게시판 선택 2버튼(주식 | 코인). 선택은 honeyTint + honey 테두리 + 체크, 나머지는 흰 배경 + line.
class BoardSegment extends StatelessWidget {
  const BoardSegment({required this.board, required this.onChanged, super.key});

  /// 1 주식, 2 코인
  final int board;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _option(1)),
        const SizedBox(width: NbkSpacing.lg),
        Expanded(child: _option(2)),
      ],
    );
  }

  Widget _option(int value) {
    final selected = value == board;
    return Material(
      color: selected ? NbkColors.honeyTint : NbkColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NbkRadius.button),
        side: BorderSide(color: selected ? NbkColors.honey : NbkColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onChanged(value),
        child: SizedBox(
          height: NbkSize.button,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: NbkSize.iconSm, color: NbkColors.honeyDeep),
                const SizedBox(width: NbkSpacing.xs + NbkSpacing.xxs),
              ],
              Text(
                Strings.boardName(value),
                style: selected
                    ? NbkTypography.buttonSmall
                    : NbkTypography.buttonSmall.copyWith(
                        color: NbkColors.text2,
                        fontWeight: FontWeight.w500,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
