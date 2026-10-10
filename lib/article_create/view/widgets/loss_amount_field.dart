import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';

/// 손실액 입력(높이 64): 왼쪽 '-', 오른쪽 정렬 숫자(천 단위 콤마 자동), 뒤에 '원'.
/// 아래에 한글 금액 보조 표기(비어 있으면 안내 문구). [error] 면 테두리가 danger 가 된다.
class LossAmountField extends StatelessWidget {
  const LossAmountField({
    required this.controller,
    required this.onChanged,
    this.error = false,
    super.key,
  });

  final TextEditingController controller;

  /// 숫자만 남긴 값('1250000')
  final ValueChanged<String> onChanged;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final borderColor = error ? NbkColors.danger : NbkColors.line;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: NbkSize.lossInputBox,
          padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.xl),
          decoration: BoxDecoration(
            color: error ? NbkColors.dangerTint : NbkColors.bg,
            borderRadius: BorderRadius.circular(NbkRadius.input),
            border: Border.all(color: borderColor, width: NbkSize.inputBorder),
          ),
          child: Row(
            children: [
              Text(
                '-',
                style: NbkTypography.lossInput.copyWith(color: NbkColors.text3),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  inputFormatters: const [ThousandsInputFormatter()],
                  style: NbkTypography.lossInput,
                  onChanged: (text) => onChanged(text.replaceAll(RegExp(r'[^0-9]'), '')),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: NbkTypography.lossInput.copyWith(color: NbkColors.text2),
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: NbkSpacing.sm),
              Text(
                '원',
                style: NbkTypography.heading.copyWith(color: NbkColors.text2),
              ),
            ],
          ),
        ),
        const SizedBox(height: NbkSpacing.sm),
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, __) {
            final amount = parseLossAmount(value.text);
            return Text(
              amount > 0 ? toKoreanWon(amount) : Strings.lossHelper,
              style: NbkTypography.caption,
            );
          },
        ),
      ],
    );
  }
}
