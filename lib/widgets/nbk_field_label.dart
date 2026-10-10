import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 입력 항목 라벨. 필수면 빨간 `*`, 오른쪽에 `0/40` 카운터, 오류면 라벨이 dangerText.
class NbkFieldLabel extends StatelessWidget {
  const NbkFieldLabel({
    required this.label,
    this.required = false,
    this.counter,
    this.error = false,
    super.key,
  });

  final String label;
  final bool required;
  final String? counter;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final style = NbkTypography.labelStrong.copyWith(
      color: error ? NbkColors.dangerText : NbkColors.text1,
    );
    return Row(
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: style,
            children: [
              if (required)
                TextSpan(text: ' *', style: style.copyWith(color: NbkColors.danger)),
            ],
          ),
        ),
        const Spacer(),
        if (counter != null) Text(counter!, style: NbkTypography.caption),
      ],
    );
  }
}
