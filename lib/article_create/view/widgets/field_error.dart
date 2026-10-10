import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 입력 항목 아래 인라인 오류 한 줄(아이콘 + dangerText)
class FieldError extends StatelessWidget {
  const FieldError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: NbkSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: NbkSize.iconXs, color: NbkColors.danger),
          const SizedBox(width: NbkSpacing.xs + NbkSpacing.xxs),
          Expanded(
            child: Text(
              message,
              style: NbkTypography.caption.copyWith(color: NbkColors.dangerText),
            ),
          ),
        ],
      ),
    );
  }
}
